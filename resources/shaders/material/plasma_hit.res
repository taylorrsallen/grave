RSRC                    VisualShader            �7ؙ٤�p                                            K      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    billboard_type    keep_scale    script    input_name    parameter_name 
   qualifier    texture_type    color_default    texture_filter    texture_repeat    texture_source    source    texture 	   operator    code    graph_offset    mode    modes/blend    modes/depth_draw    modes/cull    modes/diffuse    modes/specular    flags/depth_prepass_alpha    flags/depth_test_disabled    flags/sss_mode_skin    flags/unshaded    flags/wireframe    flags/skip_vertex_transform    flags/world_vertex_coords    flags/ensure_correct_normals    flags/shadows_disabled    flags/ambient_light_disabled    flags/shadow_to_opacity    flags/vertex_lighting    flags/particle_trails    flags/alpha_to_coverage     flags/alpha_to_coverage_and_one    flags/debug_shadow_splits    flags/fog_disabled    nodes/vertex/0/position    nodes/vertex/2/node    nodes/vertex/2/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        (   local://VisualShaderNodeBillboard_2ou7t �      $   local://VisualShaderNodeInput_mgg6s )	      1   local://VisualShaderNodeTexture2DParameter_657af u	      &   local://VisualShaderNodeTexture_vsqgm �	      &   local://VisualShaderNodeFloatOp_tmhdm 
      0   res://resources/shaders/material/plasma_hit.res H
         VisualShaderNodeBillboard                               VisualShaderNodeInput                    	         color       #   VisualShaderNodeTexture2DParameter    
         hit_texture                   VisualShaderNodeTexture                                      VisualShaderNodeFloatOp                      VisualShader          �  shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx, unshaded;

uniform sampler2D hit_texture : source_color;



void vertex() {
	mat4 n_out2p0;
// GetBillboardMatrix:2
	{
		mat4 __wm = mat4(normalize(INV_VIEW_MATRIX[0]), normalize(INV_VIEW_MATRIX[1]), normalize(INV_VIEW_MATRIX[2]), MODEL_MATRIX[3]);
		__wm = __wm * mat4(vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		__wm = __wm * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
		n_out2p0 = VIEW_MATRIX * __wm;
	}


// Output:0
	MODELVIEW_MATRIX = n_out2p0;


}

void fragment() {
// Input:2
	vec4 n_out2p0 = COLOR;
	float n_out2p4 = n_out2p0.a;


	vec4 n_out4p0;
// Texture2D:4
	n_out4p0 = texture(hit_texture, UV);
	float n_out4p4 = n_out4p0.a;


// FloatOp:5
	float n_out5p0 = n_out4p4 * n_out2p4;


// Output:0
	ALBEDO = vec3(n_out2p0.xyz);
	ALPHA = n_out5p0;


}
          .             /   
   ��O�y�[C0                     
   1   
     D   C2            3   
     ��   C4            5   
     ��  �C6            7   
     ��  �C8            9   
     �C  �C:                                                                                   RSRC