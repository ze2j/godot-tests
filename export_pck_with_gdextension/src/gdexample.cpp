#include "gdexample.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;


GDExample::GDExample()
{
}

GDExample::~GDExample()
{
}

void GDExample::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("get_amplitude"), &GDExample::get_amplitude);
	ClassDB::bind_method(D_METHOD("set_amplitude", "p_amplitude"), &GDExample::set_amplitude);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "amplitude"), "set_amplitude", "get_amplitude");

	ClassDB::bind_method(D_METHOD("get_speed"), &GDExample::get_speed);
	ClassDB::bind_method(D_METHOD("set_speed", "p_speed"), &GDExample::set_speed);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "speed", PROPERTY_HINT_RANGE, "0,20,0.01"), "set_speed", "get_speed");

	ADD_SIGNAL(MethodInfo("position_changed", PropertyInfo(Variant::OBJECT, "node"), PropertyInfo(Variant::VECTOR2, "new_pos")));
}

void GDExample::_process(double delta)
{
	time_passed += speed * delta;

	Vector2 new_position = Vector2(
			amplitude + (amplitude * sin(time_passed * 2.0)),
			amplitude + (amplitude * cos(time_passed * 1.5))
		);

	set_position(new_position);

	time_emit += delta;
	if (time_emit > 1.0)
	{
		emit_signal("position_changed", this, new_position);
		time_emit = 0.0;
	}
}

double GDExample::get_amplitude() const
{
	return amplitude;
}

void GDExample::set_amplitude(const double value)
{
	amplitude = value;
}

double GDExample::get_speed() const
{
	return speed;
}

void GDExample::set_speed(double value)
{
	speed = value;
}
