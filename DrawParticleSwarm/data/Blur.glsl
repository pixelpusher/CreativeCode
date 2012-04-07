uniform sampler2D tex;
uniform vec2 offset;

uniform float blurRatio;		// current ratio of blur iterations we are doing
uniform float blurThresh;		// threshold to check against blurring or not


void main(void)
{
	float dx = offset.s;
	float dy = offset.t;
		
	vec4 result;
	
	vec2 st = gl_TexCoord[0].st;//	vec4 vecDepth = vec4(depth, depth, depth, 1);

	vec4 color	 = 4.0 * texture2D(tex, st);
	
	float brightness = dot(vec4(0.30, 0.59, 0.11, 0.0), color);	// brightness of pixel
	
	if(brightness >  4.0 * blurThresh) {

	// Apply 3x3 gaussian filter
	color		+= 2.0 * texture2D(tex, st + vec2(+dx, 0.0));
	color		+= 2.0 * texture2D(tex, st + vec2(-dx, 0.0));
	color		+= 2.0 * texture2D(tex, st + vec2(0.0, +dy));
	color		+= 2.0 * texture2D(tex, st + vec2(0.0, -dy));
	color		+= texture2D(tex, st + vec2(+dx, +dy));
	color		+= texture2D(tex, st + vec2(-dx, +dy));
	color		+= texture2D(tex, st + vec2(-dx, -dy));
	color		+= texture2D(tex, st + vec2(+dx, -dy));

		result = color / 16.0;
	} else {
		result = color / 4.0;
	}
	
	gl_FragColor = clamp(result, 0.0, 1.0);
}
