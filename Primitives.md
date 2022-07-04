# Spheres

https://www.shadertoy.com/view/7sdfRX
```glsl
#define OBJECT Object(vec3(0, 1, 6), 1.)

struct Object{
    vec3 pos;
    float radius;
};

float dist(vec3 pos, Object obj){
    return length(pos-obj.pos)-obj.radius;
}
```

# Cubes

https://www.shadertoy.com/view/sdtBzX
```glsl
#define OBJECT Object(vec3(0, 1, 6), 1.)

struct Object{
    vec3 pos;
    float side;
};

float dist(vec3 pos, Object obj){
    vec3 q = abs(pos-obj.pos) - vec3(obj.side);
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
```
