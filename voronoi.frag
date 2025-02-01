// voronoi.frag
#ifdef GL_ES
precision mediump float;
#endif

extern vec2 u_resolution;
extern float u_time;

vec3 hash3(vec2 p) {
    vec3 q = vec3(
        dot(p, vec2(127.1, 311.7)), 
        dot(p, vec2(269.5, 183.3)), 
        dot(p, vec2(419.2, 371.9))
    );
    return fract(sin(q) * 43758.5453);
}

float voronoi(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float min_dist = 1.0; // Minimum distance to a point

    // Iterate over neighboring cells
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(x, y);
            vec3 random = hash3(i + neighbor); // Random offset for each cell

            // Animate the random points using time
            vec2 point = neighbor + 0.5 + 0.5 * sin(u_time * 0.1 + 6.2831 * random.xy) - f;
            float dist = length(point);

            if (dist < min_dist) {
                min_dist = dist; // Update minimum distance
            }
        }
    }

    return min_dist;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / u_resolution;
    uv *= 10.0; // Scale the UV coordinates to control the cell size

    float f = voronoi(uv); // Generate Voronoi pattern

    // Visualize the Voronoi diagram
    vec3 col = vec3(f); // Use distance to color the cells
    return vec4(col, 1.0);
}