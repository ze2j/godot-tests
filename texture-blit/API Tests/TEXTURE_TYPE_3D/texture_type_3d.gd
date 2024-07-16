@tool
extends BlittingTest

var _tex_src: Texture3DRD = null
var _tex_dst: Texture3DRD = null

const DEPTH := 3
const SRC_SIZE := 128
const SRC_MIPMAPS := 7

func _render() -> void:
	# Load the source images in their own layer
	var src_data: PackedByteArray
	for m in range(SRC_MIPMAPS + 1):
		var depth_m: int = max(1, DEPTH / (2 ** m))
		if depth_m == 1:
			var img: Image = load("res://Assets/src_avg.png")
			img.srgb_to_linear()
			img.resize(img.get_width() / (2 ** m), img.get_height() / (2 ** m), Image.INTERPOLATE_BILINEAR)
			src_data.append_array(img.get_data())
		else:
			for d in range(depth_m):
				var img: Image = load("res://Assets/src_" + String.num_int64(d) + ".png")
				img.srgb_to_linear()
				img.resize(img.get_width() / (2 ** m), img.get_height() / (2 ** m), Image.INTERPOLATE_BILINEAR)
				src_data.append_array(img.get_data())

	# Transfer the source image and its mipmaps to the source texture
	var tf : RDTextureFormat = RDTextureFormat.new()
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_3D
	tf.width = SRC_SIZE
	tf.height = SRC_SIZE
	tf.depth = DEPTH
	tf.array_layers = 1
	tf.mipmaps = SRC_MIPMAPS + 1
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_src_rd_rid: RID = _rd.texture_create(tf, RDTextureView.new(), [src_data])
	_tex_src = Texture3DRD.new()
	_tex_src.set_texture_rd_rid(tex_src_rd_rid)

	# Display the source texture's layer and mipmap
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("depth_slice", 0.)
	$"Panel/Src 0".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("depth_slice", 0.5)
	$"Panel/Src 1".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("tex", _tex_src)
	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("depth_slice", 1)
	$"Panel/Src 2".get_surface_override_material(0).set_shader_parameter("mipmap", src_mipmap)

	# Create an empty texture (the destination) with room for mipmaps and layers
	var tf_blit : RDTextureFormat = RDTextureFormat.new()
	tf_blit.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf_blit.texture_type = RenderingDevice.TEXTURE_TYPE_3D
	tf_blit.width = dst_texture_size.x
	tf_blit.height = dst_texture_size.y
	tf_blit.depth = dst_texture_size.z
	tf_blit.array_layers = 1
	tf_blit.mipmaps = floor(log(max(dst_texture_size.x, dst_texture_size.y, dst_texture_size.z)) / log(2))
	tf_blit.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT + RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	var tex_dst_rd_rid: RID = _rd.texture_create(tf_blit,  RDTextureView.new())
	_tex_dst = Texture3DRD.new()
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
	$Panel/Dst.get_surface_override_material(0).set_shader_parameter("depth_slice", dst_depth_slice)
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
