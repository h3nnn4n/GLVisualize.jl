{{GLSL_VERSION}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};
struct Grid1D{
    float minimum;
    float maximum;
    int dims;
};
struct Grid2D{
    vec2 minimum;
    vec2 maximum;
    ivec2 dims;
};
struct Grid3D{
    vec3 minimum;
    vec3 maximum;
    ivec3 dims;
};
struct Light{
    vec3 diffuse;
    vec3 specular;
    vec3 ambient;
    vec3 position;
};

// stretch is
vec3 stretch(vec3 val, vec3 from, vec3 to){
    return from + (val * (to - from));
}
vec2 stretch(vec2 val, vec2 from, vec2 to){
    return from + (val * (to - from));
}
float stretch(float val, float from, float to){
    return from + (val * (to - from));
}

float _normalize(float val, float from, float to){return (val-from) / (to - from);}
vec2 _normalize(vec2 val, vec2 from, vec2 to){
    return (val-from) * (to - from);
}
vec3 _normalize(vec3 val, vec3 from, vec3 to){
    return (val-from) * (to - from);
}


mat4 getmodelmatrix(vec3 xyz, vec3 scale){
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

mat4 rotationmatrix_z(float angle){
    return mat4(
        cos(angle), -sin(angle), 0, 0,
        sin(angle), cos(angle), 0,  0,
        0, 0, 1, 0,
        0, 0, 0, 1);
}
mat4 rotationmatrix_y(float angle){
    return mat4(
        cos(angle), 0, sin(angle), 0,
        0, 1, 0, 0,
        -sin(angle), 0, cos(angle), 0,
        0, 0, 0, 1);
}

const vec3 UP_VECTOR = vec3(0,0,1);
mat4 rotation_mat(vec3 direction){
    direction = normalize(direction);
    mat4 rot = mat4(1.0);
    if(direction == UP_VECTOR)
        return rot;
    vec3 xaxis = normalize(cross(UP_VECTOR, direction));

    vec3 yaxis = normalize(cross(direction, xaxis));

    rot[0][0] = xaxis.x;
    rot[1][0] = yaxis.x;
    rot[2][0] = direction.x;

    rot[0][1] = xaxis.y;
    rot[1][1] = yaxis.y;
    rot[2][1] = direction.y;

    rot[0][2] = xaxis.z;
    rot[1][2] = yaxis.z;
    rot[2][2] = direction.z;

    return rot;
}
void rotate(Nothing r, int index, in vec3 vertices, in vec3 normal){} // no-op
void rotate(samplerBuffer vectors, int index, inout vec3 V, inout vec3 N){
    vec3 r = texelFetch(vectors, index).xyz;
    mat4 rot = rotation_mat(r);
    V = vec3(rot*vec4(V, 1));
    N = normalize(vec3(rot*vec4(N, 1)));
}
void rotate(vec3 direction, in vec3 vertices, in vec3 normal, int index){}


mat4 translate_scale(vec3 xyz, vec3 scale){
   return mat4(
      vec4(scale.x, 0, 0, 0),
      vec4(0, scale.y, 0, 0),
      vec4(0, 0, scale.z, 0),
      vec4(xyz, 1));
}

//Mapping 1D index to 1D, 2D and 3D arrays
int ind2sub(int dim, int linearindex){return linearindex;}
ivec2 ind2sub(ivec2 dim, int linearindex){
    return ivec2(linearindex % dim.x, linearindex / dim.x);
}
ivec3 ind2sub(ivec3 dim, int linearindex){
    return ivec3(linearindex / (dim.y * dim.z), (linearindex / dim.z) % dim.y, linearindex % dim.z);
}

float linear_index(int dims, int index){
    return float(index) / float(dims);
}
vec2 linear_index(ivec2 dims, int index){
    ivec2 index2D = ind2sub(dims, index);
    return vec2(index2D) / vec2(dims);
}
vec2 linear_index(ivec2 dims, int index, vec2 offset){
    vec2 index2D = vec2(ind2sub(dims, index))+offset;
    return index2D / vec2(dims);
}
vec3 linear_index(ivec3 dims, int index){
    ivec3 index3D = ind2sub(dims, index);
    return vec3(index3D) / vec3(dims);
}
vec4 linear_texture(sampler2D tex, int index){
    return texture(tex, linear_index(textureSize(tex, 0), index));
}

vec4 linear_texture(sampler2D tex, int index, vec2 offset){
    ivec2 dims = textureSize(tex, 0);
    return texture(tex, linear_index(dims, index) + (offset/vec2(dims)));
}

vec4 linear_texture(sampler3D tex, int index){
    return texture(tex, linear_index(textureSize(tex, 0), index));
}
uvec4 getindex(usampler2D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(samplerBuffer tex, int index){
    return texelFetch(tex, index);
}
vec4 getindex(sampler1D tex, int index){
    return texelFetch(tex, index, 0);
}
vec4 getindex(sampler2D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}
vec4 getindex(sampler3D tex, int index){
    return texelFetch(tex, ind2sub(textureSize(tex, 0), index), 0);
}




vec3 _position(Grid1D grid, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return vec3(stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum), 0,0);
}
vec3 _position(Grid1D grid, Nothing position_x, Nothing position_y, float position_z, int index){
    return vec3(stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum), 0,position_z);
}
vec3 _position(Grid1D grid, Nothing position_x, float position_y, Nothing position_z, int index){
    return vec3(stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum), position_y, 0);
}
vec3 _position(Grid2D grid, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return vec3(stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum), 0);
}
vec3 _position(Grid2D grid, Nothing position_x, Nothing position_y, float position_z, int index){
    return vec3(stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum), position_z);
}
vec3 _position(Grid3D grid, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return stretch(linear_index(grid.dims, index), grid.minimum, grid.maximum);
}

vec3 _position(samplerBuffer position, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return texelFetch(position, index).xyz;
}
vec3 _position(Nothing position, samplerBuffer position_x, samplerBuffer position_y, samplerBuffer position_z, int index){
    return vec3(texelFetch(position_x, index).x, texelFetch(position_y, index).x, texelFetch(position_z, index).x);
}
vec3 _position(samplerBuffer position, Nothing position_x, Nothing position_y, float position_z, int index){
    return vec3(texelFetch(position, index).xy, position_z);
}
vec3 _position(samplerBuffer position, Nothing position_x, float position_y, float position_z, int index){
    return vec3(texelFetch(position, index).x, position_y, position_z);
}
vec3 _position(Nothing position, float position_x, float position_y, float position_z, int index){
    return vec3(position_x, position_y, position_z);
}
vec3 _position(vec3 position, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return position;
}
vec3 _position(vec2 position, Nothing position_x, Nothing position_y, Nothing position_z, int index){
    return vec3(position,0);
}



vec3 _scale(vec3  scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return scale;}
vec3 _scale(vec2  scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return vec3(scale,1);}
vec3 _scale(float scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){return vec3(scale);}
vec3 _scale(Nothing  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale_x, scale_y, scale_z);
}
vec3 _scale(vec2  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale_x, scale_y, scale_z);
}
vec3 _scale(vec3  scale, float scale_x, float scale_y, float scale_z, int index){
    return vec3(scale_x, scale_y, scale_z);
}
vec3 _scale(samplerBuffer scale, Nothing scale_x, Nothing scale_y, Nothing scale_z, int index){
    return getindex(scale, index).xyz;
}
vec3 _scale(vec3 scale, float scale_x, float scale_y, samplerBuffer scale_z, int index){
    return vec3(scale_x, scale_y, getindex(scale_z, index).x);
}
vec3 _scale(vec3 scale, float scale_x, samplerBuffer scale_y, float scale_z, int index){
    return vec3(scale_x, getindex(scale_y, index).x, scale_z);
}


vec4 color_lookup(float intensity, vec4 color, vec2 norm){
    return color;
}
vec4 color_lookup(float intensity, sampler1D color_ramp, vec2 norm){
    return texture(color_ramp, _normalize(intensity, norm.x, norm.y));
}

vec4 _color(vec4 color, Nothing intensity, Nothing color_norm, int index){return color;}
vec4 _color(samplerBuffer color, Nothing intensity, Nothing color_norm, int index){
    return texelFetch(color, index);
}
vec4 _color(sampler1D color, samplerBuffer intensity, vec2 color_norm, int index){
    return color_lookup(texelFetch(intensity, index).x, color, color_norm);
}
vec4 _color(sampler1D color, float intensity, vec2 color_norm, int index){
    return color_lookup(intensity, color, color_norm);
}



out vec3 o_normal;
out vec3 o_lightdir;
out vec3 o_vertex;


void render(vec3 vertex, vec3 normal, mat4 viewmodel, mat4 projection, vec3 light[4])
{
    vec4 position_camspace  = viewmodel * vec4(vertex,  1);
    // normal in world space
    o_normal                = normal;
    // direction to light
    o_lightdir              = normalize(light[3] - vertex);
    // direction to camera
    o_vertex                = -position_camspace.xyz;
    // screen space coordinates of the vertex
    gl_Position             = projection * position_camspace;
}
