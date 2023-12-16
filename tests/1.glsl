#https://www.shadertoy.com/view/4fsGzH

#define MAX_DISTANCE 100.
#define SURFACE_DISTANCE .01

////////////////////////////////////////////////////
struct Sphere{
    vec3 pos;
    float radius;
};
float dSphere(vec3 pos, Sphere obj){
    return length(pos-obj.pos)-obj.radius;
}
////////////////////////////////////////////////////
struct Cube{
    vec3 pos;
    float side;
};
float dCube(vec3 pos, Cube obj){
  vec3 q = abs(pos-obj.pos) - vec3(obj.side);
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - .1;
}
////////////////////////////////////////////////////
struct Pyramid{
    vec3 pos;
    float height;
    float side;
};
float dPyramid(vec3 pos, Pyramid obj){
  pos = pos - obj.pos - vec3(0,-obj.height*.5,0);
  float m2 = obj.height*obj.height + 0.25;
    
  pos.xz = abs(pos.xz);
  pos.xz = (pos.z>pos.x) ?pos.zx : pos.xz;
  pos.xz -= 0.5;

  vec3 q = vec3( pos.z, obj.height*pos.y - 0.5*pos.x, obj.height*pos.x + 0.5*pos.y);
   
  float s = max(-q.x,0.0);
  float t = clamp( (q.y-0.5*pos.z)/(m2+0.25), 0.0, 1.0 );
    
  float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
  float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
  float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
  return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-pos.y));
}
////////////////////////////////////////////////////

#define SPHERE Sphere(vec3(0, 1, 10), 1.)
#define CUBE Cube(vec3(3, 1, 10), 1.)
#define PYRAMID Pyramid(vec3(-3, 1, 10), 2., 1.)

float getDistance(vec3 position){
    float dSPHERE = dSphere(position, SPHERE);
    float dCUBE = dCube(position, CUBE);
    float dPYRAMID = dPyramid(position, PYRAMID);
    return min(min(min(position.y, dSPHERE), dCUBE), dPYRAMID);
}

struct Ray{
    vec3 origin, direction;
};


vec4 rayMarch(Ray ray){
	float distanceFromOrigin=0.;
    while(true){
    	vec3 position = ray.origin + ray.direction * distanceFromOrigin;
        float dist = getDistance(position);
        distanceFromOrigin += dist;
        if(distanceFromOrigin>MAX_DISTANCE || dist<SURFACE_DISTANCE) break;
    }
    return vec4(ray.origin + ray.direction * distanceFromOrigin, distanceFromOrigin);
}

vec3 getNormal(vec3 position) {
	float dist = getDistance(position);
    vec2 e = vec2(.01, 0);
    vec3 normal = dist - vec3(
        getDistance(position-e.xyy),
        getDistance(position-e.yxy),
        getDistance(position-e.yyx));
    return normalize(normal);
}

float getLight(vec3 position) {
    vec3 lightPos = vec3(0, 5, 6);
    lightPos.xz += vec2(sin(iTime), cos(iTime))*2.;
    vec3 light = normalize(lightPos-position);
    vec3 normal = getNormal(position);
    float dif = clamp(dot(normal, light), 0., 1.);
    vec4 dist = rayMarch(Ray(position+normal*SURFACE_DISTANCE*2., light));
    if(dist.w<length(lightPos-position)) dif *= .1;
    return dif;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
    Ray ray = Ray(vec3(0, 1, 0), normalize(vec3(uv.x, uv.y, 1)));
    vec4 result = rayMarch(ray);
    float dif = getLight(result.xyz);
    vec3 col = vec3(dif);
    col = pow(col, vec3(.4545));
    fragColor = vec4(col,1.0);
}
