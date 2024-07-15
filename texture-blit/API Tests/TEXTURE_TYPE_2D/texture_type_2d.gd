@tool
extends Base

var _tex_src: Texture2DRD = null
var _tex_dst: Texture2DRD = null

func _render() -> void:
	################################################################################
	# SRC
	################################################################################
	var img: Image = load("res://API Tests/TEXTURE_TYPE_2D/src.png")
	img.generate_mipmaps()
	img.srgb_to_linear()

	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf.width = img.get_width()
	tf.height = img.get_height()
	tf.depth = 1
	tf.array_layers = 1
	tf.mipmaps = img.get_mipmap_count() + 1
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_src_rd_rid: RID = _rd.texture_create(tf, RDTextureView.new(), [img.get_data()])

	_tex_src = Texture2DRD.new()
	_tex_src.set_texture_rd_rid(tex_src_rd_rid)

	$Panel/Src.get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$Panel/Src.get_surface_override_material(0).set_shader_parameter("lod", src_mipmap)

	################################################################################
	# DST
	################################################################################

	var tf_blit : RDTextureFormat = RDTextureFormat.new()
	tf_blit.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_blit.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf_blit.width = dst_texture_size.x
	tf_blit.height = dst_texture_size.y
	tf_blit.depth = 1
	tf_blit.array_layers = 1
	tf_blit.mipmaps = img.get_mipmap_count() + 1
	tf_blit.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT

	var tex_dst_rd_rid: RID = _rd.texture_create(tf_blit,  RDTextureView.new())
	_rd.texture_blit(tex_src_rd_rid, tex_dst_rd_rid,
					 _src_region_from, _dst_region_from,
					 _src_region_size, _dst_region_size,
					 src_mipmap, dst_mipmap,
					 src_layer, dst_layer,
					 _filter)

	_tex_dst = Texture2DRD.new()
	_tex_dst.set_texture_rd_rid(tex_dst_rd_rid)

	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", _tex_dst)
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("lod", dst_mipmap)

func _cleanup():
	if _tex_src != null:
		_rd.free_rid(_tex_src.get_texture_rd_rid())
		_tex_src = null
		$Panel/Src.get_surface_override_material(0).set_shader_parameter("tex", null)

	if _tex_dst != null:
		_rd.free_rid(_tex_dst.get_texture_rd_rid())
		_tex_dst = null
		$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", null)
