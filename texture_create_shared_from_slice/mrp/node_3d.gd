extends Node3D

var rd: RenderingDevice
var texture_array_rid: RID
var shared_rids: Array

const LAYERS := 1024
const IMG_SIZE := 128
const MIPMAPS := 8 # 7 + 1 for the base level


func _ready() -> void:
	initialize()

func _exit_tree():
	cleanup()

func _on_button_pressed() -> void:
	print("creating shared textures")
	create_shared_textures()
	print("done")

########################################################################################################################

func initialize():
	rd = RenderingServer.get_rendering_device()

	var layer_data: Array[PackedByteArray]
	var img: Image = load("res://icon.png")
	img.generate_mipmaps()
	img.srgb_to_linear()
	for i in range(LAYERS):
		layer_data.push_back(img.get_data())

	var texture_array_format : RDTextureFormat = RDTextureFormat.new()
	texture_array_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	texture_array_format.texture_type = RenderingDevice.TEXTURE_TYPE_2D_ARRAY
	texture_array_format.width = IMG_SIZE
	texture_array_format.height = IMG_SIZE
	texture_array_format.depth = 1
	texture_array_format.array_layers = LAYERS
	texture_array_format.mipmaps = MIPMAPS
	texture_array_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT

	texture_array_rid = rd.texture_create(texture_array_format, RDTextureView.new(), layer_data)


func create_shared_textures():
	for layer in range(LAYERS):
		for mipmap_level in range(MIPMAPS):
			var shared_rid: RID = rd.texture_create_shared_from_slice(RDTextureView.new(), texture_array_rid, layer, mipmap_level, 1, RenderingDevice.TEXTURE_SLICE_2D)
			shared_rids.push_back(shared_rid)


func cleanup():
	for shared_rid in shared_rids:
		rd.free_rid(shared_rid)
	rd.free_rid(texture_array_rid)
