module dlgl.util;

import std.stdio,
	std.traits;
import derelict.opengl3.gl3;

/**
 * Executes the OpenGL function named by op.  If version debugGL is enabled,
 *  glGetError is checked before and after the call.
 */
auto gl(string op, T...)(T args)
{
	// Pre-function check
	version(debugGL)
	{
		auto e = glGetError();
		if (e != GL_NO_ERROR)
			stderr.writeln("GL ERROR: ", e, " before calling "~op);
	}

	// Actually execute the function--store the return value if the function
	//  returns anything.
	static if (is(ReturnType!(mixin("gl"~op)) == void))
		mixin("gl"~op~"(args);");
	else
		mixin("auto ret = gl"~op~"(args);");

	// Post-function check
	version(debugGL)
	{
		e = glGetError();
		if (e != GL_NO_ERROR)
			stderr.writeln("GL ERROR: ", e, " after calling "~op);
	}

	static if (is(typeof(ret)))
		return ret;
}

/// Parameterized on a type, resolves to the appropriate GL_* type enum
template glType(T : byte) { enum glType = GL_BYTE; }
template glType(T : ubyte) { enum glType = GL_UNSIGNED_BYTE; }
template glType(T : short) { enum glType = GL_SHORT; }
template glType(T : ushort) { enum glType = GL_UNSIGNED_SHORT; }
template glType(T : int) { enum glType = GL_INT; }
template glType(T : uint) { enum glType = GL_UNSIGNED_INT; }
template glType(T : float) { enum glType = GL_FLOAT; }
template glType(T : double) { enum glType = GL_DOUBLE; }
