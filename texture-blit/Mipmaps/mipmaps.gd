@tool
extends Node3D

@export var src_size: Vector2i:
	get:
		return _src_size
	set(value):
		if value != _src_size:
			_src_size = value
			_dirty = true

# Lower bound is 1 to get a base level
# Upper bound bigger than  1 + log2(texture.size) to test error management
@export_range(1, 16) var mipmaps: int:
	get:
		return _mipmaps
	set(value):
		if value != _mipmaps:
			_mipmaps = value
			_dirty = true

@export var filter: RenderingDevice.SamplerFilter:
	get:
		return _filter
	set(value):
		if value != _filter:
			_filter = value
			_dirty = true

var _src_size: Vector2i = Vector2i(128, 128)
var _mipmaps: int = 8
var _filter := RenderingDevice.SAMPLER_FILTER_LINEAR
var _dirty := true

var _rd: RenderingDevice = null
var _shader_rid: RID = RID()
var _pipeline_rid: RID = RID()
var _uniform_set_rid: RID = RID()
var _tex_original: Texture2DRD = null
var _shared_rids: Array[RID]

const PANEL_ITEM_SIZE := 4


func _ready() -> void:
	_rd = RenderingServer.get_rendering_device()

func _exit_tree():
	_cleanup()

func _process(delta: float) -> void:
	if not _dirty:
		return
	_dirty = false

	_cleanup()
	_setup()
	_render_base_texture()
	_generate_mipmaps()
	_display_mipmaps()

func _setup():
	var shader_file = load("res://Mipmaps/compute_shader.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	_shader_rid = _rd.shader_create_from_spirv(shader_spirv)
	_pipeline_rid = _rd.compute_pipeline_create(_shader_rid)

	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = _src_size.x
	tf.height = _src_size.y
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = _mipmaps
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + \
					RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	var tex_original_rd_rid: RID = _rd.texture_create(tf, RDTextureView.new(), [])

	_tex_original = Texture2DRD.new()
	_tex_original.set_texture_rd_rid(tex_original_rd_rid)

	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0
	uniform.add_id(_tex_original.get_texture_rd_rid())

	_uniform_set_rid = _rd.uniform_set_create([uniform], _shader_rid, 0)

func _render_base_texture():
	var compute_list := _rd.compute_list_begin()
	_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline_rid)
	_rd.compute_list_bind_uniform_set(compute_list, _uniform_set_rid, 0)
	_rd.compute_list_dispatch(compute_list, _src_size.x / 8, _src_size.y / 8, 1)
	_rd.compute_list_end()

func _generate_mipmaps():
	var base_rid: RID = _rd.texture_create_shared_from_slice(RDTextureView.new(), _tex_original.get_texture_rd_rid(), 0, 0)
	_shared_rids.push_back(base_rid)

	for m in range(1, _mipmaps):
		print_debug("Generating mipmap level " + String.num_int64(m))

		var src_rid: RID = _shared_rids[m-1]

		var dst_rid: RID = _rd.texture_create_shared_from_slice(RDTextureView.new(), _tex_original.get_texture_rd_rid(), 0, m)
		_shared_rids.push_back(dst_rid)

		var tf_src : RDTextureFormat = _rd.texture_get_format(src_rid)
		var tf_dst : RDTextureFormat = _rd.texture_get_format(dst_rid)
		_rd.texture_blit(src_rid, dst_rid,
						Vector3i(), Vector3i(),
						Vector3i(tf_src.width, tf_src.height, 0), Vector3i(tf_dst.width, tf_dst.height, 0),
						0, 0, # We use shared textures so the mipmaps are relative to them
						0, 0,
						_filter)

func _display_mipmaps():
	var mesh := QuadMesh.new()
	mesh.size = Vector2(PANEL_ITEM_SIZE, PANEL_ITEM_SIZE)

	var mat := ShaderMaterial.new()
	mat.shader = load("res://Mipmaps/display.gdshader")
	mat.set_shader_parameter("tex", _tex_original)

	for i in range(_mipmaps):
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		mi.transform.origin.x += 1.1 * PANEL_ITEM_SIZE * i
		mi.set_surface_override_material(0, mat)
		mi.set_instance_shader_parameter("lod", i)
		$Panel.add_child(mi)


func _cleanup_panel():
	var mesh_instances := $Panel.get_children()
	for mi in mesh_instances:
		mi.get_surface_override_material(0).set_shader_parameter("tex", null)
		$Panel.remove_child(mi)
		mi.queue_free()

func _cleanup_shared_rids():
	for rid: RID in _shared_rids:
		_rd.free_rid(rid)
	_shared_rids.clear()

func _cleanup():
	_cleanup_panel()

	if _pipeline_rid.is_valid():
		_rd.free_rid(_pipeline_rid)

	if _uniform_set_rid.is_valid():
		_rd.free_rid(_uniform_set_rid)

	if _shader_rid.is_valid():
		_rd.free_rid(_shader_rid)

	_cleanup_shared_rids()

	if _tex_original != null:
		_rd.free_rid(_tex_original.get_texture_rd_rid())
		_tex_original = null
