#pragma once

#include <godot_cpp/classes/sprite2d.hpp>


namespace godot
{
	class GDExample : public Sprite2D
	{
		GDCLASS(GDExample, Sprite2D)

	public:
		GDExample();
		~GDExample();

	protected:
		static void _bind_methods();

	public:
		void _process(double delta) override;

		double get_amplitude() const;
		void set_amplitude(const double value);

		double get_speed() const;
		void set_speed(double value);

	private:
		double time_passed = 0.0;
		double time_emit = 0.0;
		double amplitude = 10.0;
		double speed = 1.0;
	};
}

