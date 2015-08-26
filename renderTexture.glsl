
	#version 120

	#define N 25
	vec2 P[N] = vec2[](vec2(63.458964,74.683401), vec2(281.456003,87.388435), vec2(441.167234,-29.660635), vec2(726.884485,43.110289), vec2(927.034685,26.415172), vec2(208.279997,176.992208), vec2(408.047817,299.693049), vec2(461.317542,256.812381), vec2(837.348258,225.453216), vec2(943.569934,301.762077), vec2(67.739277,462.994726), vec2(228.321532,412.094033), vec2(604.358539,465.999605), vec2(625.707055,480.895192), vec2(845.895900,517.043756), vec2(209.736032,561.990434), vec2(497.660530,920.883116), vec2(418.967734,735.747090), vec2(720.397355,820.725323), vec2(779.453621,841.462952), vec2(121.917279,931.678671), vec2(128.535235,714.178013), vec2(365.148299,812.894129), vec2(819.070938,894.852004), vec2(941.611730,846.761790));

	uniform vec2 iResolution;

	vec3 hue(float h, float s) {
		float v=1.0;
		if (s==0.0) return vec3(v);
		int i = int(floor(h*6.0));
		float f = (h*6.)-i;
		float p = (v*(1.-s));
		float q = (v*(1.-s*f));
		float t = (v*(1.-s*(1.-f)));
		i= int(mod(i,6));
		if (i == 0) return vec3(v, t, p);
		if (i == 1) return vec3(q, v, p);
		if (i == 2) return vec3(p, v, t);
		if (i == 3) return vec3(p, q, v);
		if (i == 4) return vec3(t, p, v);
		if (i == 5) return vec3(v, p, q);
	}

	void main() {
		float region=-1, dist;
		float minDistance = length(iResolution);
		vec2 minPos;

		for(int i=0; i<N; i++) {
			vec2 pos = P[i];
			dist = abs(pos.x - gl_TexCoord[0].x) + abs(pos.y - gl_TexCoord[0].y);

			if(dist <= minDistance) {
				minPos= pos;
				minDistance = dist;
				region = float(i+1) / float(N+1);
			}
		}

		float H= int(sqrt(N));
		gl_FragColor = vec4(hue(region*N/H,region) , 1.0);
	}