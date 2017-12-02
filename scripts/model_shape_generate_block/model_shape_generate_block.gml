/// model_shape_generate_block(angle)
/// @arg angle
/// @desc Generates a block shape bent by the given angle.

var angle = argument0;

// Block dimensions
var x1, x2, y1, y2, z1, z2, size;
x1 = from[X];	y1 = from[Y];	z1 = from[Z]
x2 = to[X];		y2 = to[Y];		z2 = to[Z]
size = point3D_sub(to, from)

// Axis to split up the block
var segaxis = Z;
if (angle != 0)
{
	if (bend_part = e_part.LEFT || bend_part = e_part.RIGHT)
		segaxis = X
	else if (bend_part = e_part.BACK || bend_part = e_part.FRONT)
		segaxis = Y
	else if (bend_part = e_part.LOWER || bend_part = e_part.UPPER)
		segaxis = Z
}

// Define texture coordinates to use
var texsize, texsizefix, texuv;
texsize = point3D_sub(to_noscale, from_noscale)
texsizefix = point3D_sub(texsize, vec3(1 / 256)) // Artifact fix with CPU rendering

// Convert to 0-1
texsize = vec3(texsize[X] / texture_size[X], texsize[Y] / texture_size[Y], texsize[Z] / texture_size[Y])
texsizefix = vec3(texsizefix[X] / texture_size[X], texsizefix[Y] / texture_size[Y], texsizefix[Z] / texture_size[Y])
texuv = vec2_div(uv, texture_size)

// Block face texture mapping
var texeast1, texeast2, texeast3, texeast4;
var texwest1, texwest2, texwest3, texwest4;
var texsouth1, texsouth2, texsouth3, texsouth4;
var texnorth1, texnorth2, texnorth3, texnorth4;
var texstart1, texstart2, texstart3, texstart4;
var texend1, texend2, texend3, texend4;
var texup1, texup2, texup3, texup4;
var texdown1, texdown2, texdown3, texdown4;

texeast1 = point2D_add(texuv, point2D(texsize[X], 0))
texeast2 = point2D_add(texeast1, point2D(texsizefix[Y], 0))
texeast3 = point2D_add(texeast1, point2D(texsizefix[Y], texsizefix[Z]))
texeast4 = point2D_add(texeast1, point2D(0, texsizefix[Z]))

texwest1 = point2D_sub(texuv, point2D(texsize[Y], 0))
texwest2 = point2D_add(texwest1, point2D(texsizefix[Y], 0))
texwest3 = point2D_add(texwest1, point2D(texsizefix[Y], texsizefix[Z]))
texwest4 = point2D_add(texwest1, point2D(0, texsizefix[Z]))

texsouth1 = point2D_copy(texuv)
texsouth2 = point2D_add(texsouth1, point2D(texsizefix[X], 0))
texsouth3 = point2D_add(texsouth1, point2D(texsizefix[X], texsizefix[Z]))
texsouth4 = point2D_add(texsouth1, point2D(0, texsizefix[Z]))

texnorth1 = point2D_add(texeast1, point2D(texsize[Y], 0))
texnorth2 = point2D_add(texnorth1, point2D(texsizefix[X], 0))
texnorth3 = point2D_add(texnorth1, point2D(texsizefix[X], texsizefix[Z]))
texnorth4 = point2D_add(texnorth1, point2D(0, texsizefix[Z]))

texup1 = point2D_sub(texuv, point2D(0, texsize[Y]))
texup2 = point2D_add(texup1, point2D(texsizefix[X], 0))
texup3 = point2D_add(texup1, point2D(texsizefix[X], texsizefix[Y]))
texup4 = point2D_add(texup1, point2D(0, texsizefix[Y]))

texdown4 = point2D_add(texup1, point2D(texsize[X], 0)) // Down is flipped vertically
texdown3 = point2D_add(texdown4, point2D(texsizefix[X], 0))
texdown2 = point2D_add(texdown4, point2D(texsizefix[X], texsizefix[Y]))
texdown1 = point2D_add(texdown4, point2D(0, texsizefix[Y]))

// Mirror texture on X
if (texture_mirror)
{
	// Switch east/west sides
	var tmp1, tmp2, tmp3, tmp4;
	tmp1 = texeast1; tmp2 = texeast2; tmp3 = texeast3; tmp4 = texeast4;
	texeast1 = texwest1; texeast2 = texwest2; texeast3 = texwest3; texeast4 = texwest4;
	texwest1 = tmp1; texwest2 = tmp2; texwest3 = tmp3; texwest4 = tmp4;
	
	// Switch left/right points
	tmp1 = texeast1; texeast1 = texeast2; texeast2 = tmp1
	tmp1 = texeast3; texeast3 = texeast4; texeast4 = tmp1
	tmp1 = texwest1; texwest1 = texwest2; texwest2 = tmp1
	tmp1 = texwest3; texwest3 = texwest4; texwest4 = tmp1
	tmp1 = texsouth1; texsouth1 = texsouth2; texsouth2 = tmp1
	tmp1 = texsouth3; texsouth3 = texsouth4; texsouth4 = tmp1
	tmp1 = texnorth1; texnorth1 = texnorth2; texnorth2 = tmp1
	tmp1 = texnorth3; texnorth3 = texnorth4; texnorth4 = tmp1
	tmp1 = texup1; texup1 = texup2; texup2 = tmp1
	tmp1 = texup3; texup3 = texup4; texup4 = tmp1
	tmp1 = texdown1; texdown1 = texdown2; texdown2 = tmp1
	tmp1 = texdown3; texdown3 = texdown4; texdown4 = tmp1
}

var detail = 2;
var bendstart, bendend, bendsegsize, invangle;
bendsegsize = bend_size / detail;
invangle = (bend_part = e_part.LOWER || bend_part = e_part.BACK || bend_part = e_part.LEFT)

// Start position and bounds
var p1, p2, p3, p4;
var texp1, texp2, texp3;
switch (segaxis)
{
	case X:
	{
		bendstart = (bend_offset - (position[X] + x1)) - bend_size / 2
		bendend = (bend_offset - (position[X] + x1)) + bend_size / 2
		p1 = point3D(x1, y1, z2)
		p2 = point3D(x1, y2, z2)
		p3 = point3D(x1, y2, z1)
		p4 = point3D(x1, y1, z1)
		texp1 = texsouth1[X] // South/Above X
		texp2 = texnorth2[X] // North X
		texp3 = texdown4[X] // Below X
		texstart1 = texwest1; texstart2 = texwest2; texstart3 = texwest3; texstart4 = texwest4;
		texend1 = texeast1; texend2 = texeast2; texend3 = texeast3; texend4 = texeast4;
		break
	}
	
	case Y:
	{
		bendstart = (bend_offset - (position[Y] + y1)) - bend_size / 2
		bendend = (bend_offset - (position[Y] + y1)) + bend_size / 2
		p1 = point3D(x2, y1, z2)
		p2 = point3D(x1, y1, z2)
		p3 = point3D(x1, y1, z1)
		p4 = point3D(x2, y1, z1)
		texp1 = texeast2[X] // East X
		texp2 = texwest1[X] // West X
		texp3 = texup1[Y] // Above/Below Y
		texstart1 = texnorth1; texstart2 = texnorth2; texstart3 = texnorth3; texstart4 = texnorth4;
		texend1 = texsouth1; texend2 = texsouth2; texend3 = texsouth3; texend4 = texsouth4;
		break
	}
	
	case Z:
	{
		bendstart = (bend_offset - (position[Z] + z1)) - bend_size / 2
		bendend = (bend_offset - (position[Z] + z1)) + bend_size / 2
		p1 = point3D(x1, y2, z1)
		p2 = point3D(x2, y2, z1)
		p3 = point3D(x2, y1, z1)
		p4 = point3D(x1, y1, z1)
		texp1 = texsouth3[Y] // East/South/West/North Y
		texstart1 = texdown1; texstart2 = texdown2; texstart3 = texdown3; texstart4 = texdown4;
		texend1 = texup1; texend2 = texup2; texend3 = texup3; texend4 = texup4;
		break
	}
}

// Angle
var cangle = 0;
if (bendend < 0) // Above bend, apply full angle
	cangle = angle
else if (bendstart < 0) // Start inside bend, apply partial angle
	cangle = (1 - bendend / bend_size) * angle

// Apply bending transform
if (angle != 0)
{
	var mat = model_part_get_bend_matrix(id, invangle ? (angle - cangle) : cangle, vec3(0));
	p1 = point3D_mul_matrix(p1, mat)
	p2 = point3D_mul_matrix(p2, mat)
	p3 = point3D_mul_matrix(p3, mat)
	p4 = point3D_mul_matrix(p4, mat)
}

vbuffer_start()

var segpos = 0;
while (true)
{
	// End face
	if (segpos = size[segaxis])
	{
		switch (segaxis)
		{
			case X: case Y:
			{
				// Flip left/right positions
				vbuffer_add_triangle(p2, p1, p4, texend1, texend2, texend3, null, color_blend, color_alpha, invert)
				vbuffer_add_triangle(p4, p3, p2, texend3, texend4, texend1, null, color_blend, color_alpha, invert)
				break
			}
			
			case Z:
			{
				// Flip top/bottom positions
				vbuffer_add_triangle(p4, p3, p2, texend1, texend2, texend3, null, color_blend, color_alpha, invert)
				vbuffer_add_triangle(p2, p1, p4, texend3, texend4, texend1, null, color_blend, color_alpha, invert)
				break
			}
		}
		break
	}
	
	// Start face
	if (segpos = 0)
	{
		vbuffer_add_triangle(p1, p2, p3, texstart1, texstart2, texstart3, null, color_blend, color_alpha, invert)
		vbuffer_add_triangle(p3, p4, p1, texstart3, texstart4, texstart1, null, color_blend, color_alpha, invert)
	}
	
	var segsize, np1, np2, np3, np4, ntexp1, ntexp2, ntexp3;
	
	// Find segment size
	if (angle = 0 || segpos >= bendend) // No/Above bend
		segsize = size[segaxis] - segpos
	else if (segpos < bendstart) // Below bend
		segsize = min(size[segaxis] - segpos, bendstart)
	else // Within bend
	{
		segsize = bendsegsize
		
		if (segpos = 0) // Start inside bend, apply partial size
			segsize -= (from[segaxis] - bendstart) % bendsegsize
		
		segsize = min(size[segaxis] - segpos, segsize)
		cangle += angle / detail
	}
			
	// Advance
	segpos += segsize
	switch (segaxis)
	{
		case X:
		{
			// West points
			np1 = point3D(x1 + segpos, y1, z2)
			np2 = point3D(x1 + segpos, y2, z2)
			np3 = point3D(x1 + segpos, y2, z1)
			np4 = point3D(x1 + segpos, y1, z1)
			var toff = (segpos / size[X]) * texsizefix[X] * negate(texture_mirror);
			texp1 = texsouth1[X] + toff // South/Above X
			texp2 = texnorth2[X] - toff // North X
			texp3 = texdown4[X] + toff // Below X
			break
		}
		
		case Y:
		{
			// South points
			np1 = point3D(x2, y1 + segpos, z2)
			np2 = point3D(x1, y1 + segpos, z2)
			np3 = point3D(x1, y1 + segpos, z1)
			np4 = point3D(x2, y1 + segpos, z1)
			var toff = (segpos / size[Y]) * texsizefix[Y];
			ntexp1 = texeast2[X] - toff * negate(texture_mirror) // East X
			ntexp2 = texwest1[X] + toff * negate(texture_mirror) // West X
			ntexp3 = texup1[Y] + toff // Above/Below Y
			break
		}
		
		case Z:
		{
			// Upper points
			np1 = point3D(x1, y2, z1 + segpos)
			np2 = point3D(x2, y2, z1 + segpos)
			np3 = point3D(x2, y1, z1 + segpos)
			np4 = point3D(x1, y1, z1 + segpos)
			var toff = (segpos / size[Z]) * texsizefix[Z];
			ntexp1 = texsouth3[Y] - toff // East/South/West/North Y
			break
		}
	}
	
	// Apply bending transform
	if (angle != 0)
	{
		var nmat = model_part_get_bend_matrix(id, invangle ? (angle - cangle) : cangle, vec3(0));
		np1 = point3D_mul_matrix(np1, nmat)
		np2 = point3D_mul_matrix(np2, nmat)
		np3 = point3D_mul_matrix(np3, nmat)
		np4 = point3D_mul_matrix(np4, nmat)
	}
	
	// Add surrounding faces
	var t1, t2, t3, t4;
	switch (segaxis)
	{
		case X:
		{
			// South
			t1 = vec2(texp1, texsouth1[Y])
			t2 = vec2(ntexp1, texsouth1[Y])
			t3 = vec2(ntexp1, texsouth3[Y])
			t4 = vec2(texp1, texsouth3[Y])
			vbuffer_add_triangle(p2, np2, np3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(np3, p3, p2, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// North
			t1 = vec2(ntexp2, texnorth1[Y])
			t2 = vec2(texp2, texnorth1[Y])
			t3 = vec2(texp2, texnorth3[Y])
			t4 = vec2(ntexp2, texnorth3[Y])
			vbuffer_add_triangle(np1, p1, p4, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p4, np4, np1, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// Up
			t1 = vec2(texp1, texup1[Y])
			t2 = vec2(ntexp1, texup1[Y])
			t3 = vec2(ntexp1, texup3[Y])
			t4 = vec2(texp1, texup3[Y])
			vbuffer_add_triangle(p1, np1, np2, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(np2, p2, p1, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// Down
			t1 = vec2(texp3, texdown1[Y])
			t2 = vec2(ntexp3, texdown1[Y])
			t3 = vec2(ntexp3, texdown3[Y])
			t4 = vec2(texp3, texdown3[Y])
			vbuffer_add_triangle(p3, np3, np4, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(np4, p4, p3, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			texp1 = ntexp1; texp2 = ntexp2; texp3 = ntexp3;
			break
		}
		
		case Y:
		{
			// East
			t1 = vec2(ntexp1, texeast1[Y])
			t2 = vec2(texp1, texeast1[Y])
			t3 = vec2(texp1, texeast3[Y])
			t4 = vec2(ntexp1, texeast3[Y])
			vbuffer_add_triangle(np1, p1, p4, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p4, np4, np1, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// West
			t1 = vec2(texp2, texwest1[Y])
			t2 = vec2(ntexp2, texwest1[Y])
			t3 = vec2(ntexp2, texwest3[Y])
			t4 = vec2(texp2, texwest3[Y])
			vbuffer_add_triangle(p2, np2, np3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(np3, p3, p2, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// Up
			t1 = vec2(texup1[X], texp3)
			t2 = vec2(texup2[X], texp3)
			t3 = vec2(texup2[X], ntexp3)
			t4 = vec2(texup1[X], ntexp3)
			vbuffer_add_triangle(p2, p1, np1, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(np1, np2, p2, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			// Down
			t1 = vec2(texdown1[X], ntexp3)
			t2 = vec2(texdown2[X], ntexp3)
			t3 = vec2(texdown2[X], texp3)
			t4 = vec2(texdown1[X], texp3)
			vbuffer_add_triangle(np3, np4, p4, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p4, p3, np3, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			texp1 = ntexp1; texp2 = ntexp2; texp3 = ntexp3;
			break
		}
		
		case Z:
		{
			// East
			t1 = vec2(texeast1[X], ntexp1)
			t2 = vec2(texeast2[X], ntexp1)
			t3 = vec2(texeast2[X], texp1)
			t4 = vec2(texeast1[X], texp1)
			vbuffer_add_triangle(np2, np3, p3, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p3, p2, np2, t3, t4, t1, null, color_blend, color_alpha, invert)
	
			// West
			t1 = vec2(texwest1[X], ntexp1)
			t2 = vec2(texwest2[X], ntexp1)
			t3 = vec2(texwest2[X], texp1)
			t4 = vec2(texwest1[X], texp1)
			vbuffer_add_triangle(np4, np1, p1, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p1, p4, np4, t3, t4, t1, null, color_blend, color_alpha, invert)
	
			// South
			t1 = vec2(texsouth1[X], ntexp1)
			t2 = vec2(texsouth2[X], ntexp1)
			t3 = vec2(texsouth2[X], texp1)
			t4 = vec2(texsouth1[X], texp1)
			vbuffer_add_triangle(np1, np2, p2, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p2, p1, np1, t3, t4, t1, null, color_blend, color_alpha, invert)
	
			// North
			t1 = vec2(texnorth1[X], ntexp1)
			t2 = vec2(texnorth2[X], ntexp1)
			t3 = vec2(texnorth2[X], texp1)
			t4 = vec2(texnorth1[X], texp1)
			vbuffer_add_triangle(np3, np4, p4, t1, t2, t3, null, color_blend, color_alpha, invert)
			vbuffer_add_triangle(p4, p3, np3, t3, t4, t1, null, color_blend, color_alpha, invert)
			
			texp1 = ntexp1
			break
		}
	}
	
	p1 = np1; p2 = np2; p3 = np3; p4 = np4;
}

return vbuffer_done()