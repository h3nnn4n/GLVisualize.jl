{{GLSL_VERSION}}
{{GLSL_EXTENSIONS}}

in vec2 vertices;

uniform usamplerBuffer glyphs;
uniform samplerBuffer positions;
uniform usamplerBuffer style_index;

uniform sampler2D uvs;
uniform sampler1D styles;

uniform mat4 projectionviewmodel;

uvec4 getindex(usampler2D tex, int index);
vec4 getindex(sampler2D tex, int index);

out vec2 o_uv;
out vec4 o_color;


vec2 getuv(vec4 attributes, int vertexid)
{
	if(vertexid == 1)
		return attributes.xy;
	if(vertexid == 0)
		return attributes.xw;
	if(vertexid == 3)
		return attributes.zw;
	if(vertexid == 2)
		return attributes.zy;

}
void main(){
	int   index		  = gl_InstanceID;
    uint  glyph 	  = texelFetch(glyphs, index).x;
    vec4  uv_dims  	  = texelFetch(uvs, ivec2(glyph, 0), 0);
    vec4  attributes2 = texelFetch(uvs, ivec2(glyph, 1), 0);
    
    vec2  bearing 	  = attributes2.xy;
    vec2  glyph_scale = attributes2.zw;

    vec2  position	  = texelFetch(positions, index).xy+bearing;
    uvec2  style_i    = texelFetch(style_index, index).xy;

    o_uv 			  = getuv(uv_dims, gl_VertexID);
    o_color 		  = texelFetch(styles, int(style_i.x), 0);
    gl_Position       = projectionviewmodel * vec4(position + (vertices*glyph_scale), 0, 1); 
}