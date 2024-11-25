// Variables for part dimensions
part_width = 145.5; //mm
part_height = 55; //mm
part_depth = 8;    //mm
toleranceForHeatmapContact = 1.0;
dokariSize = 8.6; //mm

// Variables for hole dimensions and positions
hole_diameter = 2.6;  // Diameter of the screw holes
hole_diameter_sonar = 2.0;  // Diameter of the screw holes
hole_depth = part_depth + 2;  // Ensure hole passes through the part
hole_horiz_dist = 95;  // Horizontal distance between the center and the hole (in mm, 9.5 cm)
hole_vert_dist = 40;   // Vertical distance between the center and the hole (in mm, 4 cm)

 module prism(l, w, h)
 {
      polyhedron(//pt 0        1        2        3        4        5
              points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
              faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
              );
}

// Function to create one part with holes
module hex_part_with_holes(width, height, depth) 
{
    difference() 
    {
        rotate([0, 0, 0])
        cube([width, height, depth]);  // The main part
        // Create holes on the part
        //for (i = [-1, 1]) 
        {
            translate([0, hole_vert_dist / 10, depth / 2])
            rotate([90, 0, 105])
            cylinder(h=hole_depth, d=hole_diameter);
            
            translate([10, hole_vert_dist / 10, depth / 2])
            rotate([90, 0, 105])
            cylinder(h=hole_depth, d=hole_diameter);

        }
    }
}

module dokari()
{
   cylinder(h=300, d=dokariSize);
}



// Function to create one part with holes
module hex_part(width, height, depth) 
{  
     offsetX = 28.2;
     translate([width/3 - offsetX,height,0])
     cube([offsetX, height/6, depth*2]);  // The main part  
     translate([width/3 + width/3,height,0])
     cube([offsetX, height/6, depth*2]);  // The main part  
    
     textEngrave = 1.5;
     protrudeForLaserRangeFinder = 34; //24 Can't see because of light
    
     difference() 
    {
      {//Thiki gia dokari
        translate([width/3,height,0])
        cube([width/3, height/3, protrudeForLaserRangeFinder]);  // The main part  
      }
      {
          
          
       //Engraving   
       {
        translate([width/3+13,height+10,protrudeForLaserRangeFinder -   textEngrave+1]) 
        linear_extrude(textEngrave)
        text( "ICS-FORTH", size= 3);
       }
       {
        translate([width/3+8,height+5,protrudeForLaserRangeFinder -   textEngrave+1]) 
        linear_extrude(textEngrave)
        text( " MAGICIAN CAMERA v0.3", size= 2);
       }


          
        //Eisodos gia dokari
        translate([width/2+13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          }
        translate([width/2,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          }
        translate([width/2-13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          }
          
          //Vides aristera deksia gia laser range sensor
         translate([width/2-10,260,protrudeForLaserRangeFinder-2.5])
          {
           rotate([90.0, 0, 0]) 
           cylinder(h=300, d=hole_diameter);
          }
         translate([width/2+10,260,protrudeForLaserRangeFinder-2.5])
          {
           rotate([90.0, 0, 0]) 
           cylinder(h=300, d=hole_diameter);
          }
          
          //Vides aristera deksia gia sonar range sensor
         translate([width/2-21,260,protrudeForLaserRangeFinder-2.5])
          {
           rotate([90.0, 0, 0]) 
           cylinder(h=300, d=hole_diameter_sonar);
          }
         translate([width/2+21,260,protrudeForLaserRangeFinder-2.5])
          {
           rotate([90.0, 0, 0]) 
           cylinder(h=300, d=hole_diameter_sonar);
          }


          
      }
   }
   
   /*
   //See dokaria
   //-------------------------------------------------------------
            //          DISABLE FROM HERE
   //-------------------------------------------------------------
       translate([width/2 +13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
   
       translate([width/2,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
 
       translate([width/2 -13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
   //-------------------------------------------------------------
            //          DISABLE UNTIL HERE
   //-------------------------------------------------------------
 */
          
          
     difference() 
    {
      {
        cube([width, height, depth]);  // The main part
      }
      {
         smallHole=1.8;
        //Holes for heat shield down
        translate([width/2-25,5,depth-10])
         {
           //Hole for heat shield left down
           cylinder(h=300, d=smallHole);
         }
        translate([width/2+25,5,depth-10])
         { //Hole for heat shield right down
           cylinder(h=300, d=smallHole);
         }


        //Holes for heat shield up
        translate([width/2-25,51.5,depth-10])
         {
           //Hole for heat shield left up
           cylinder(h=300, d=smallHole);
         } 
        translate([width/2+25,51.5,depth-10])
         { //Hole for heat shield right up
           cylinder(h=300, d=smallHole);
         }
         
          
        translate([width/2,height/2,depth-1])
         {
             heatShieldIntentationLength = 85;
             holeMarginLength = 0;
             
            {
             // Metal Heatshield slot indendation
             translate([-heatShieldIntentationLength/2,-24.5,0])
             cube([heatShieldIntentationLength, 50, depth+3]);  
            }
            {
             // Metal Heatshield vent hole to the other side
             translate([-heatShieldIntentationLength/2 + holeMarginLength,-18,-80])
             cube([heatShieldIntentationLength - 2* holeMarginLength, 36, 85]);  
            }
         }
         
         
         
      }
    }
    
    
    {
     translate([width/2,height/2,depth])
     {
      //See part center  
      //cylinder(h=hole_depth, d=hole_diameter); 
         
         
      //We are at center
      //Add triangles left/right
      triangleTolerance = 2; //degrees
      triangleDepth = 8;
       {
            translate([77.7,-27.5,-triangleDepth])
            rotate([triangleTolerance, 0, 90])
            prism(55, 5, triangleDepth);
       }
       {
            translate([77.7,-27.5,-triangleDepth])
            rotate([0, 0, 90])
            prism(55, 5, triangleDepth);
       }
       
       
      //Add triangles left/right
       {
            translate([-77.7,27.5,-triangleDepth])
            rotate([triangleTolerance, 0, -90])
            prism(55, 5, triangleDepth);
       }
       {
            translate([-77.7,27.5,-triangleDepth])
            rotate([0, 0, -90])
            prism(55, 5, triangleDepth);
       }


       offsetX = -5;
      //Fixing for light

     difference() 
     { //right screwing point
            {
               translate([47.5+offsetX,-27.5,0])
               cube([10, height, depth-toleranceForHeatmapContact]);  
            }   
           { //Screwing hole 
             translate([52.5+offsetX,-20,0])
             cylinder(h=hole_depth, d=hole_diameter);
           } 
           { //Screwing hole
             translate([52.5+offsetX,20,0])
             cylinder(h=hole_depth, d=hole_diameter);              
           }
      }
               
     difference() 
     { //left screwing point
            {
                translate([-47.5+offsetX,-27.5,0])
                cube([10, height, depth-toleranceForHeatmapContact]);  //left screwing point
            }    
           {
             translate([-42.5+offsetX,-20,0])
             cylinder(h=hole_depth, d=hole_diameter);              
           }
           {
             translate([-42.5+offsetX,20,0])
             cylinder(h=hole_depth, d=hole_diameter);              
           }
    }

  }
 }
 
 
}


module hex_part_with_holes(width, height, depth) 
{ 
     difference() 
    {
        hex_part(width,height,depth);
        {
         //Holes that tie a hex_part with other hex parts
         //Left 
          translate([0.0,10,-10])  // Up 
          cylinder(h=100, d=4);             
          translate([0.0,45,-10]) //Down
          cylinder(h=100, d=4);        
        
          //Right 
          translate([part_width,10,-10]) //Up
          cylinder(h=100, d=4);             
          translate([part_width,45,-10]) //Down
          cylinder(h=100, d=4);          
        }
    }
}

module support_holes()
{       //Holes
       translate([part_width/2 +13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
   
       translate([part_width/2,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
 
       translate([part_width/2 -13,342,110])
          {
           rotate([109.0, 0, 0])
           dokari(); 
          } 
}


module adapter_box() 
{
    difference() 
    {
        // Camera Box Bottom plate
        rotate([0, 0, 52]) //Correct orientation
        cube([95, 95, 10], center = true);  // Adjust size as necessary 
        
    {
     // Cutout for lens 
     translate([0.0, 0.0, 05])
            cylinder(r = 14.15, h = 80, center = true);

    //Add holes for camera 
    for (i = [0:4]) 
     {
        rotate([0, 0, i * 90])
         {
           //Hole 1
           rotate([0, 0, 52]) //Correct orientation
             translate([-49.5,-27.5,-1])
                cube([10, 1.3, 1.3]);

            //Hole 2
            rotate([0, 0, 52]) //Correct orientation
              translate([-49.5,27.5,-1])
                 cube([10, 1.3, 1.3]);
          } // End of rotating these holes for every side
      } //End of for loop for holes
    } //End of difference
       
    } //This is where camera stands
}



module camera_box_without_cable_holes()
{
  difference()
   {
      translate([0, 0, 310]) 
     {
       // Render the adapter box
       adapter_box();
      }
   
       for (i = [0:5]) 
      {
        rotate([0, 0, i * 60])
        translate([part_width+5.0, -part_height / 2, 0])
        {
          rotate([90, 0, -128.70])
         support_holes();
        }
       }
   }


    translate([0, 0, 320]) 
    {
      difference() 
       {
        rotate([0, 0, 52]) //Correct orientation
          cube([82, 82, 10], center = true);  // Adjust size as 
        
           translate([0.0, 0.0, 05])
            cylinder(r = 29.15, h = 80, center = true);
       }
    } 
}


module camera_box()
{
      cable_hole_size_radious = 3.15;
    
      difference() 
       {
         camera_box_without_cable_holes();
           
           //Punch holes for cables
         {  
           translate([24.0, 0.0, 320])
            cylinder(r =cable_hole_size_radious, h = 80, center = true);

           translate([-24.0, 0.0, 320])
            cylinder(r = cable_hole_size_radious, h = 80, center = true);

           translate([0.0, 24.0, 320])
            cylinder(r = cable_hole_size_radious, h = 80, center = true);
             
           translate([0.0, -24.0, 320])
            cylinder(r =cable_hole_size_radious, h = 80, center = true);
         }
       }
}



module support_box(count)
{
 difference()
 {
  {
      for (z = [0:count]) 
      {
        rotate([0, 0, z * 60])
        translate([part_width+5.0, -part_height / 2, 0])
        {
          rotate([90, 0, -128.70])
            {
               support_holes();  
            } 
        }

      //Middle binder for each beam
      //for (i = [0:count]) 
      {
          rotate([0, 0,-120+ 60 *z])
             translate([12, 83, 170]) 
               rotate([20, 0, -10])
                 cube([42, 10, 20], center = true);  // Adjust size as 
      }

      //Bottom support printing each beam
     // for (i = [0:count]) 
      {
          rotate([0, 0, -120+60 *z])
             translate([11.5, 81, 189]) 
               rotate([19.1, 0, -10])
                 cube([42, 02, 246], center = true);  // Adjust size as 
      }
        
        
     }
  }
   
  //CUT beams above camera!
  translate([0, 0, 340]) 
        cube([95, 95, 50], center = true);  // Adjust size as necessary 
   
 }
}








// Main module to create hexagon using 6 parts with holes
module light_hexagon() 
{ 
   
    //Straight line where the camera is
    dokari(); 
    
    for (i = [0:5]) 
     {
        rotate([0, 0, i * 60])
        translate([part_width+5.0, -part_height / 2, 0])
        {
        rotate([90, 0, -128.70])
        //hex_part(part_width, part_height, part_depth);
        hex_part_with_holes(part_width, part_height, part_depth);
        }
    }
}




//Select what to print here

//support_box(0); //0 for 3D print one at a time
support_box(5); //5 for everything
camera_box(); 
light_hexagon();



//hex_part_with_holes(part_width, part_height, part_depth);
