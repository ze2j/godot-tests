@tool
extends BlitTest

var _tex_src: Texture2DRD = null
var _tex_dst: Texture2DRD = null

func _render() -> void:
	# Load a source image with mipmaps in RAM
	var img: Image = load("res://Assets/src.png")
	img.generate_mipmaps()
	img.srgb_to_linear()

	# Transfer the source image and its mipmaps to the source texture
	var tf_src : RDTextureFormat = RDTextureFormat.new()
	tf_src.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_src.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf_src.width = img.get_width()
	tf_src.height = img.get_height()
	tf_src.depth = 1
	tf_src.array_layers = 1
	tf_src.mipmaps = img.get_mipmap_count() + 1
	tf_src.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_src_rd_rid: RID = rd.texture_create(tf_src, RDTextureView.new(), [img.get_data()])
	_tex_src = Texture2DRD.new()
	_tex_src.set_texture_rd_rid(tex_src_rd_rid)

	# Display the source texture's mipmap
	$Panel/Src.get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$Panel/Src.get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	# Create an empty texture (the destination) with room for mipmaps
	var tf_dst : RDTextureFormat = RDTextureFormat.new()
	tf_dst.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_dst.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	tf_dst.width = dst_texture_size.x
	tf_dst.height = dst_texture_size.y
	tf_dst.depth = 1
	tf_dst.array_layers = 1
	tf_dst.mipmaps = floor(log(max(dst_texture_size.x, dst_texture_size.y)) / log(2))
	tf_dst.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_dst_rd_rid: RID = rd.texture_create(tf_dst,  RDTextureView.new())
	_tex_dst = Texture2DRD.new()
	_tex_dst.set_texture_rd_rid(tex_dst_rd_rid)

	# Blit from the source's mipmap to the destination's mipmap
	rd.texture_blit(tex_src_rd_rid, tex_dst_rd_rid,
				 	src_region_from, dst_region_from,
					src_region_size, dst_region_size,
					src_mipmap, dst_mipmap,
					src_layer, dst_layer,
					filter)

	# Display the destination texture's mipmap
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", _tex_dst)
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("mipmap", dst_mipmap)

func _cleanup():
	if _tex_src != null:
		rd.free_rid(_tex_src.get_texture_rd_rid())
		_tex_src = null
		$Panel/Src.get_surface_override_material(0).set_shader_parameter("tex", null)

	if _tex_dst != null:
		rd.free_rid(_tex_dst.get_texture_rd_rid())
		_tex_dst = null
		$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", null)
