@tool
extends BlittingTest

var _tex_src: Texture2DArrayRD = null
var _tex_dst: Texture2DArrayRD = null

const LAYERS := 3


func _render() -> void:
	# Load the source images in their own layer
	var src_data: Array[PackedByteArray]
	var src_width := 0
	var src_height := 0
	var src_mipmaps := 0
	for i in range(LAYERS):
		var img: Image = load("res://API Tests/TEXTURE_TYPE_2D_ARRAY/src_" + String.num_int64(i) + ".png")
		img.generate_mipmaps()
		img.srgb_to_linear()
		src_data.push_back(img.get_data())
		src_width = img.get_width()
		src_height = img.get_height()
		src_mipmaps = img.get_mipmap_count()

	# Transfer the source image and its mipmaps to the source texture
	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	tf.width = src_width
	tf.height = src_height
	tf.depth = 1
	tf.array_layers = LAYERS
	tf.mipmaps = src_mipmaps + 1
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_src_rd_rid: RID = _rd.texture_create(tf, RDTextureView.new(), src_data)
	_tex_src = Texture2DArrayRD.new()
	_tex_src.set_texture_rd_rid(tex_src_rd_rid)

	# Display the source texture's layer and mipmap
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("layer", 0)
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("layer", 1)
	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("layer", 2)
	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	# Create an empty texture (the destination) with room for mipmaps and layers
	var tf_blit : RDTextureFormat = RDTextureFormat.new()
	tf_blit.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_blit.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	tf_blit.width = dst_texture_size.x
	tf_blit.height = dst_texture_size.y
	tf_blit.depth = 1
	tf_blit.array_layers = LAYERS
	tf_blit.mipmaps = floor(log(max(dst_texture_size.x, dst_texture_size.y)) / log(2))
	tf_blit.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_dst_rd_rid: RID = _rd.texture_create(tf_blit,  RDTextureView.new())
	_tex_dst = Texture2DArrayRD.new()
	_tex_dst.set_texture_rd_rid(tex_dst_rd_rid)

	# Blit from the source's mipmap to the destination's mipmap
	_rd.texture_blit(tex_src_rd_rid, tex_dst_rd_rid,
					 _src_region_from, _dst_region_from,
					 _src_region_size, _dst_region_size,
					 src_mipmap, dst_mipmap,
					 src_layer, dst_layer,
					 _filter)

	# Display the destination texture's mipmap
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", _tex_dst)
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("layer", dst_layer)
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("mipmap", dst_mipmap)

func _cleanup():
	if _tex_src != null:
		_rd.free_rid(_tex_src.get_texture_rd_rid())
		_tex_src = null
		$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("tex", null)
		$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("tex", null)
		$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("tex", null)

	if _tex_dst != null:
		_rd.free_rid(_tex_dst.get_texture_rd_rid())
		_tex_dst = null
		$Panel/Dst.get_surface_override_material(0).set_shader_parameter("tex", null)
