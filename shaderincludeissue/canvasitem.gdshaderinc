//shader_type canvas_item;
void vertex()
{
	VERTEX += abs(sin(TIME)) * TEXTURE_PIXEL_SIZE * 100.0;
}