extends MeshInstance3D

const rings = 10
const radial_segments = 10

func _ready():
	# Create 3 surfaces (3 spheres)
	var s1 := create_surface_array(Vector3(-1, 0, 0), 1)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, s1)

	var s2 := create_surface_array(Vector3(0, 0, 0), 1)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, s2)

	var s3 := create_surface_array(Vector3(1, 0, 0), 1)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, s3)

	# Remove the surfaces one by one
	await get_tree().create_timer(3.0).timeout
	mesh.surface_remove(0)
	await get_tree().create_timer(3.0).timeout
	mesh.surface_remove(1)
	await get_tree().create_timer(3.0).timeout
	mesh.surface_remove(0)


func create_surface_array(pos: Vector3, radius: float) -> Array:
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

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
			verts.append(vert)
			normals.append(vert.normalized())
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
	return surface_array
