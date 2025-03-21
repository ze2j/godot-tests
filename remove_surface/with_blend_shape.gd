extends MeshInstance3D

var rings = 10
var radial_segments = 10

func _ready():
	mesh.blend_shape_mode = Mesh.BLEND_SHAPE_MODE_NORMALIZED

	# Create one surface with one blend shape
	var bs1 := create_blend_shape(Vector3(0, 0, 0), 2)
	mesh.add_blend_shape("bs1")
	var s1 := create_surface_array(Vector3(0, 0, 0), 1)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, s1, [bs1])

	# => A sphere with radius 1 is visible
	set_blend_shape_value(0, 0)
	await get_tree().create_timer(3.0).timeout

	# => A sphere with radius 2 is visible
	set_blend_shape_value(0, 1)
	await get_tree().create_timer(3.0).timeout

	# Remove the surface
	# => Adding new blend shapes is possible now
	mesh.surface_remove(0)
	await get_tree().create_timer(3.0).timeout

	# Create one surface with two blend shapes
	var bs2 = create_blend_shape(Vector3(0, 0, 0), 3)
	mesh.add_blend_shape("bs2")
	var s2 := create_surface_array(Vector3(0, 0, 0), 1)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, s2, [bs1, bs2])

	# => A sphere with radius 1 is visible
	set_blend_shape_value(0, 0)
	set_blend_shape_value(1, 0)
	await get_tree().create_timer(3.0).timeout

	# => A sphere with radius 2 is visible
	set_blend_shape_value(0, 1)
	set_blend_shape_value(1, 0)
	await get_tree().create_timer(3.0).timeout

	# => A sphere with radius 3 is visible
	set_blend_shape_value(0, 0)
	set_blend_shape_value(1, 1)
	await get_tree().create_timer(3.0).timeout

	# Remove the surface
	mesh.surface_remove(0)


func create_blend_shape(pos: Vector3, radius: float) -> Array:
	var bs := create_surface_array(pos, radius)
	bs[Mesh.ARRAY_TEX_UV] = null
	bs[Mesh.ARRAY_INDEX] = null
	return bs

func create_surface_array(pos: Vector3, radius: float) -> Array:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	var tangents = PackedFloat32Array()

	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = pos + Vector3(x * radius * w, y * radius, z * radius * w)
			var normal = vert.normalized()
			var tangent = vert.cross(normal)
			verts.append(vert)
			normals.append(normal)
			tangents.append(tangent.x)
			tangents.append(tangent.y)
			tangents.append(tangent.z)
			tangents.append(1.)
			uvs.append(Vector2(u, v))
			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		if i > 0:
			indices.append(prevrow + radial_segments - 1)
			indices.append(prevrow)
			indices.append(thisrow + radial_segments - 1)

			indices.append(prevrow)
			indices.append(prevrow + radial_segments)
			indices.append(thisrow + radial_segments - 1)

		prevrow = thisrow
		thisrow = point

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	surface_array[Mesh.ARRAY_TANGENT] = tangents
	return surface_array
