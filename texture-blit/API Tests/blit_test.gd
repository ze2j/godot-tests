@tool
extends Node3D
class_name BlitTest


@export var dst_texture_size: Vector3i:
	get:
		return _dst_texture_size
	set(value):
		if value != _dst_texture_size:
			_dst_texture_size = value
			_dirty = true

@export_range(0, 1) var dst_sampled_slice: float:
	get:
		return _dst_sampled_slice
	set(value):
		if value != _dst_sampled_slice:
			_dst_sampled_slice = value
			_dirty = true

@export_group("Blit Arguments")

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

@export var src_mipmap: int:
	get:
		return _src_mipmap
	set(value):
		if value != _src_mipmap:
			_src_mipmap = value
			_dirty = true

@export var dst_mipmap: int:
	get:
		return _dst_mipmap
	set(value):
		if value != _dst_mipmap:
			_dst_mipmap = value
			_dirty = true

@export var src_layer: int:
	get:
		return _src_layer
	set(value):
		if value != _src_layer:
			_src_layer = value
			_dirty = true

@export var dst_layer: int:
	get:
		return _dst_layer
	set(value):
		if value != _dst_layer:
			_dst_layer = value
			_dirty = true

var rd: RenderingDevice = null

var _dst_texture_size := Vector3i(64, 64, 0)
var _dst_sampled_slice := 0.5

var _src_region_from := Vector3i(0, 0, 0)
var _src_region_size := Vector3i(128, 128, 0)
var _dst_region_from := Vector3i(0, 0, 0)
var _dst_region_size := Vector3i(64, 64, 0)
var _src_mipmap := 0
var _dst_mipmap := 0
var _src_layer := 0
var _dst_layer := 0
var _filter := RenderingDevice.SAMPLER_FILTER_LINEAR
var _dirty := true


func _ready() -> void:
	rd = RenderingServer.get_rendering_device()

func _exit_tree():
	_cleanup()

func _process(_delta: float) -> void:
	if not _dirty:
		return
	_dirty = false

	_cleanup()
	_render()

##################################################
# Virtual methods

func _render():
	pass

func _cleanup():
	pass
