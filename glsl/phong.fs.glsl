/*
Uniforms already defined by THREE.js
------------------------------------------------------
uniform mat4 viewMatrix; = camera.matrixWorldInverse
uniform vec3 cameraPosition; = camera position in world space
------------------------------------------------------
*/

uniform sampler2D textureMask; //Texture mask, color is different depending on whether this mask is white or black.
uniform sampler2D textureNumberMask; //Texture containing the billard ball's number, the final color should be black when this mask is black.
uniform vec3 maskLightColor; //Ambient/Diffuse/Specular Color when textureMask is white
uniform vec3 materialDiffuseColor; //Diffuse color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform vec3 materialSpecularColor; //Specular color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform vec3 materialAmbientColor; //Ambient color when textureMask is black (You can assume this is the default color when you are not using textures)
uniform float shininess; //Shininess factor

uniform vec3 lightDirection; //Direction of directional light in world space
uniform vec3 lightColor; //Color of directional light
uniform vec3 ambientLightColor; //Color of ambient light

in vec3 n;
in vec3 v;
in vec2 vUv;

vec3 computePhong(vec3 ambientColor, vec3 diffuseColor, vec3 specularColor, vec3 N, vec3 L, vec3 E, vec3 R)
{
	vec3 Iamb =  ambientColor * ambientLightColor; // Iamb = Ka * Ia
	
	vec3 Idiff = diffuseColor *  lightColor * max(dot(N,L),0.0); // Idiff = Kd * Ilight * (N.L)

	vec3 Ispec = specularColor *  lightColor * pow(max(dot(R,E),0.0),shininess); // Ispec = ks * Ilight * (E.R)^shininess

	return Iamb + Idiff + Ispec;
}

void main() {
	vec3 N = normalize(n);
	vec3 L = normalize(mat3(viewMatrix) *  (-lightDirection) ); 
	vec3 E = normalize( -v );  // camera est à (0,0,0)
	vec3 R = normalize(reflect(-L,N)); 

	vec3 phongBlack = computePhong(materialAmbientColor, materialDiffuseColor, materialSpecularColor, N, L, E, R);
	vec3 phongWhite = computePhong(maskLightColor, maskLightColor, maskLightColor, N, L, E, R);

	vec4 blackWhiteMix = mix(vec4(phongBlack, 1.0), vec4(phongWhite, 1.0), texture2D(textureMask, vUv));
	gl_FragColor = mix(vec4(0.0,0.0,0.0, 1.0), blackWhiteMix, texture2D(textureNumberMask, vUv));
}