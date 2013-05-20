module dlgl.shader;

import std.file,
	std.regex,
	std.algorithm,
	std.conv,
	std.stdio;
import std.array;
import std.string : splitLines, toStringz;
import derelict.opengl3.gl3;
import gl3n.linalg;
import dlgl.util;

class Shader
{
	GLuint vertShader,
			fragShader,
			geomShader,
			program;
	alias program this;

	private this() {}

	this(string filename)
	{
		buildShaders(filename.readText());
	}

	static Shader fromString(string sources)
	{
		auto ret = new Shader;
		ret.buildShaders(sources);
		return ret;
	}

	void buildShaders(string src)
	{
		string[] directives;
		string[][string] parts;

		auto partMatch = regex(`^(\w+):`);
		string curType;
		foreach (line; src.splitLines())
		{
			if (line.startsWith("#"))
				directives ~= line;

			else {
				auto m = line.match(partMatch);

				if (m)
					curType = m.captures[1];

				else
					parts[curType] ~= line;
			}
		}

		// Get shader objects
		if (auto s = "vertex" in parts)
		{
			vertShader = gl!"CreateShader"(GL_VERTEX_SHADER);
			immutable(char*) source = toStringz((directives ~ *s).join("\n"));
			gl!"ShaderSource"(vertShader, 1, &source, null);
			if (!vertShader.compileShader())
				throw new Exception("Failed to compile vertex shader");
		}

		if (auto s = "fragment" in parts)
		{
			fragShader = gl!"CreateShader"(GL_FRAGMENT_SHADER);
			immutable(char*) source = toStringz((directives ~ *s).join("\n"));
			gl!"ShaderSource"(fragShader, 1, &source, null);
			if (!fragShader.compileShader())
				throw new Exception("Failed to compile fragment shader");
		}

		//TODO geometry shader

		// Link into a program
		program = gl!"CreateProgram"();
		gl!"AttachShader"(program, vertShader);
		gl!"AttachShader"(program, fragShader);
		gl!"LinkProgram"(program);

		// Check the program
		int ret, logLen;
		gl!"GetProgramiv"(program, GL_LINK_STATUS, &ret);
		gl!"GetProgramiv"(program, GL_INFO_LOG_LENGTH, &logLen);

		if (logLen > 0)
		{
			char[] log = new char[](logLen);
			gl!"GetProgramInfoLog"(program, logLen, null, log.ptr);
			writeln(to!string(log));
		}
		if (ret != GL_TRUE)
			throw new Exception("Failed to link shader program");

		gl!"DeleteShader"(vertShader);
		gl!"DeleteShader"(fragShader);
	}

	void bind()
	{
		gl!"UseProgram"(program);
	}

	GLint getLocation(string name)
	{
		auto ret = gl!"GetAttribLocation"(program, name.toStringz);
		if (ret < 0)
			throw new Exception("Failed to get attribute location: "~name);
		return ret;
	}

	GLint[string] uniformLocations;
	void uniform(T)(string name, T value)
	{
		GLint loc;
		if (auto vptr = name in uniformLocations)
			loc = *vptr;
		else {
			loc = gl!"GetUniformLocation"(program, name.toStringz);
			if (loc < 0)
				throw new Exception("Failed to get uniform location: "~name);
			uniformLocations[name] = loc;
		}

		static if (is(T == mat4))
			gl!"UniformMatrix4fv"(loc, 1, GL_TRUE, value.value_ptr);
		else static if (is(T == vec2))
			gl!"Uniform2fv"(loc, 1, value.value_ptr);
		else static if (is(T == vec3))
			gl!"Uniform3fv"(loc, 1, value.value_ptr);
		else static if (is(T == vec4))
			gl!"Uniform4fv"(loc, 1, value.value_ptr);
		else static if (is(T == int))
			gl!"Uniform1i"(loc, value);
		else static if (is(T == float))
			gl!"Uniform1f"(loc, value);
		else static assert(false, "Unsupported uniform type "~T.stringof);
	}

}
 
private bool compileShader(GLuint shader)
{
	gl!"CompileShader"(shader);

	// Check Vertex Shader
	int ret, logLen;
	gl!"GetShaderiv"(shader, GL_COMPILE_STATUS, &ret);
	gl!"GetShaderiv"(shader, GL_INFO_LOG_LENGTH, &logLen);

	if (logLen > 0)
	{
		char[] log = new char[](logLen);
		gl!"GetShaderInfoLog"(shader, logLen, null, log.ptr);
		version (debugGL)
			writeln(log);
	}

	return ret == GL_TRUE;
} 
