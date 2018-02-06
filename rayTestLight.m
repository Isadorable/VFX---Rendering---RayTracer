%%%%%%%%%%%%%%%%%%%%%%%%%%RAY CASTER MAIN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The following program consist in a simple implementation of a ray caster
%using the scene file (simplescene.m) available on Moodle. The result will 
%be displayed in approximately 1 minute using the standard image size.
%An example of the final result can be found in this same folder.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

%load in 'scene' as a variable
scene = simplescene;

% nH = scene.imagesize(1,:);
% nW = scene.imagesize(2,:);
nH = 50;
nW = 50;
c = scene.cam;

%the final image is initially filled with zeros
img = zeros(nH,nW,3);

%camera centre
e = scene.cam.focus;
%directional light
light = scene.directionallight;
% light = scene.directionallight(:,1);
lightColour = [0.5;0.5;0.5]; %color white
finalC = 0;

%objects reflection and refraction features
reflections = [0;0;0];
reflective = [true;true;true];
refractions = [0;0;0];
refractive = [true;false;false];
refIndices = [1.6;1;1];
refLimit = 0;

%minIntersection stores the value of t after every ray collision detection.
%components = [t,object ID, triangle ID]
minIntersection = [inf,inf,inf];
dataCoordiantes = cell(1,2);

%% RAY CASTING

for i = 1:nH
    %compute the x coordinate. We start from the centre of the pixel
    %in the top left corner
    top = 1*(((i-0.5)/nH)-0.5);
    
    for j = 1:nW
        %compute the y coordinate
        left = 1*(((j-0.5)/nW)-0.5);
        
        %compute the 3D coordinates of the i,j pixel in the nHxnW image
        q = e+c.focallength*(c.forward)+left*(c.right)-top*(c.up);
        v = (q-e)/norm(q-e);        
        
        for k = 1: scene.numofobjects
            %store the number of triangles for each object
            numTriangles = size(scene.objects{1,k}.tri,2);
            
            for l = 1: numTriangles
                %get the coordinates for the current triangle
                iCoords = scene.objects{1,k}.tri(:,l);
                p1 = scene.objects{1,k}.p(1:3,iCoords(1));
                p2 = scene.objects{1,k}.p(1:3,iCoords(2));
                p3 = scene.objects{1,k}.p(1:3,iCoords(3));
                %find the norm of the current triangle
                n = scene.objects{1,k}.n(:,l);
                %use the parametric form of a line - creation of the rays
                t = dot(p1-e,n)/dot(n,v);
                if t > 0
                    %a is intersection point of the ray with the triangles
                    a = e+t*v;
                    
                    %check if a is within the current triangle
                    r1 = dot(cross((p2-p1)/norm(p2-p1),(a-p1)/norm(a-p1)),n);
                    r2 = dot(cross((p3-p2)/norm(p3-p2),(a-p2)/norm(a-p2)),n);
                    r3 = dot(cross((p1-p3)/norm(p1-p3),(a-p3)/norm(a-p3)),n);
                    %if so, for every pixel i,j we save the value of the 
                    %smallest t which corresponds to the distance of the 
                    %closest triangle respect to the camera position
                    

                    if(r1 >= 0 && r2 >= 0 && r3 >= 0);
                        if t < minIntersection(1)
                            %k = object ID. l = n triangle for the object. n = norm
                            minIntersection = [t,k,l];
                            dataCoordiantes{1,1} = n;
                            dataCoordiantes{1,2} = a;
                        end
                    end
                    
                end
                
            end
        end
        %we set the colour of the closest triangle to the pixel i,j in the
        %final image
        if minIntersection(1) ~= inf
            triangleColour = scene.objects{1,minIntersection(2)}.colour(1:3,minIntersection(3));

            for lightsI =1:size(light,2)
                if (~checkCollision(scene,light(:,lightsI),dataCoordiantes,e))%if the point receive direct sunlight..
                    n = dataCoordiantes{1,1};
                    a = dataCoordiantes{1,2};
                    
                    %PHONG ILLUMINATION                    
                    vLight = (light(:,lightsI)-a)/norm((light(:,lightsI)-a));
                    view = (a-e)/norm(a-e);
                    %Diffuse component
                    finalC_diffuse = max(0,dot(n,vLight))*lightColour;
                    
                    %Specular component
                    h = view+vLight;
                    finalC_specular = (max(0,dot(n,h))^5)*lightColour;
                    
                    %final colour computation
                    finalC =finalC+(finalC_diffuse+finalC_specular);
                end
            end
            
            if(reflective(minIntersection(2)))
                reflections = checkReflections(scene,e,dataCoordiantes,light);
            end
            if(refractive(minIntersection(2)))
                refractions = checkRefractions(scene,e,dataCoordiantes,light,refIndices(minIntersection(2)),refIndices,refLimit+1);
            end            
            img(i,j,1:3) = (refractions+reflections+triangleColour.*scene.ambientlight+finalC);
                        
            %colour reset
            minIntersection = [inf,inf,inf];
            reflections = [0;0;0];
            refractions = [0;0;0];
            finalC = 0;
        end
    end
end
figure; imshow(img);
% beep on; beep;


