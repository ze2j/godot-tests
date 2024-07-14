@tool
extends Node3D

@export var dst_texture_size: Vector2i:
	get:
		return _dst_texture_size
	set(value):
		if value != _dst_texture_size:
			_dst_texture_size = value
			_dirty = true

@export var src_region_from: Vector3i:
	get:
		return _src_region_from
	set(value):
		if value != _src_region_from:
			_src_region_from = value
			_dirty = true

@export var src_region_size: Vector3i:
	get:
		return _src_region_size
	set(value):
		if value != _src_region_size:
			_src_region_size = value
			_dirty = true

@export var dst_region_from: Vector3i:
	get:
		return _dst_region_from
	set(value):
		if value != _dst_region_from:
			_dst_region_from = value
			_dirty = true

@export var dst_region_size: Vector3i:
	get:
		return _dst_region_size
	set(value):
		if value != _dst_region_size:
			_dst_region_size = value
			_dirty = true

@export var filter: RenderingDevice.SamplerFilter:
	get:
		return _filter
	set(value):
		if value != _filter:
			_filter = value
			_dirty = true


var _dst_texture_size := Vector2i(64, 64)

var _src_region_from := Vector3i(0, 0, 0)
var _src_region_size := Vector3i(128, 128, 0)
var _dst_region_from := Vector3i(0, 0, 0)
var _dst_region_size := Vector3i(64, 64, 0)
var _filter := RenderingDevice.SAMPLER_FILTER_LINEAR
var _dirty := true

var _rd: RenderingDevice = null
var _tex_base: Texture2DRD = null
var _tex_blitted: Texture2DRD = null


func _ready() -> void:
	_rd = RenderingServer.get_rendering_device()

func _exit_tree():
	_cleanup()

func _process(delta: float) -> void:
	if not _dirty:
		return
	_dirty = false

	_cleanup()

	var source_image: Image = load("res://icon.svg")
	source_image.srgb_to_linear()

	################################################################################
	# Base
	################################################################################

	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = source_image.get_width()
	tf.height = source_image.get_height()
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = 1
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_base_rd_rid: RID = _rd.texture_create(tf, RDTextureView.new(), [source_image.get_data()])

	_tex_base = Texture2DRD.new()
	_tex_base.set_texture_rd_rid(tex_base_rd_rid)

	$Panel/Base.get_surface_override_material(0).set_shader_parameter("tex", _tex_base)

	################################################################################
	# Blitted
	################################################################################

	var tf_blit : RDTextureFormat = RDTextureFormat.new()
	tf_blit.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_blit.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf_blit.width =_dst_texture_size.x
	tf_blit.height = _dst_texture_size.y
	tf_blit.depth = 1
	tf_blit.array_layers = 1
	tf_blit.mipmaps = 1
	tf_blit.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT

	var tex_blitted_rd_rid: RID = _rd.texture_create(tf_blit,  RDTextureView.new())
	_rd.texture_blit(tex_base_rd_rid, tex_blitted_rd_rid,
					 _src_region_from, _dst_region_from,
					 _src_region_size, _dst_region_size,
					 0, 0,
					 0, 0,
					 _filter)

	_tex_blitted = Texture2DRD.new()
	_tex_blitted.set_texture_rd_rid(tex_blitted_rd_rid)

	$Panel/Blitted.get_surface_override_material(0).set_shader_parameter("tex", _tex_blitted)

func _cleanup():
	if _tex_base != null:
		_rd.free_rid(_tex_base.get_texture_rd_rid())
		_tex_base = null
		$Panel/Base.get_surface_override_material(0).set_shader_parameter("tex", null)

	if _tex_blitted != null:
		_rd.free_rid(_tex_blitted.get_texture_rd_rid())
		_tex_blitted = null
		$Panel/Blitted.get_surface_override_material(0).set_shader_parameter("tex", null)
