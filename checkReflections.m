function rColor = checkReflections(scene,e,dataCoordiantes,light)
rColor = [0;0;0];
n = dataCoordiantes{1,1};
a = dataCoordiantes{1,2};
minIntersection = [inf,inf,inf];
lightColour = [0.5;0.5;0.5];
finalC = [0;0;0];
view = (a-e)/norm(a-e);
c1 = -dot( n, view );
ray = view + (2 * n * c1 ); 


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
        t = dot(p1-a,n)/dot(n,ray);
        if t > 0
            %a is intersection point of the ray with the triangles
            a1 = a+t*ray;
            
            %check if a is within the current triangle
            r1 = dot(cross((p2-p1)/norm(p2-p1),(a1-p1)/norm(a1-p1)),n);
            r2 = dot(cross((p3-p2)/norm(p3-p2),(a1-p2)/norm(a1-p2)),n);
            r3 = dot(cross((p1-p3)/norm(p1-p3),(a1-p3)/norm(a1-p3)),n);
            %if so, for every pixel i,j we save the value of the
            %smallest t which corresponds to the distance of the
            %closest triangle respect to the camera position
            
            d = sqrt((a1(1,:)-a(1,:))^2+(a1(2,:)-a(2,:))^2+(a1(3,:)-a(3,:))^2);
            if(r1 >= 0 && r2 >= 0 && r3 >= 0 && d > 0.0001);
                if t < minIntersection(1)
                    %k = object ID. l = n triangle for the object. n = norm
                    minIntersection = [t,k,l];
                    dataCoordiantes{1,1} = n;
                    dataCoordiantes{1,2} = a1;
                end
            end
        end
    end
end
if minIntersection(1) ~= inf
                triangleColour = scene.objects{1,minIntersection(2)}.colour(1:3,minIntersection(3));

            for lightsI =1:size(light,2)
                if (~checkCollision(scene,light(:,lightsI),dataCoordiantes,e))%if the point receive direct sunlight..
                    
                    n = dataCoordiantes{1,1};
                    a1 = dataCoordiantes{1,2};
                    
                    %PHONG ILLUMINATION                    
                    vLight = (light(:,lightsI)-a1)/norm((light(:,lightsI)-a1));
                    view = (a1-e)/norm(a1-e);
                    %Diffuse component
                    finalC_diffuse = max(0,dot(n,vLight))*lightColour;
                    
                    %Specular component
                    h = view+vLight;
                    finalC_specular = (max(0,dot(n,h))^5)*lightColour;
                    
                    %final color computation
                    finalC =finalC+(finalC_diffuse+finalC_specular);
                end
            end
            %0.2 is the reflectivity
%             rColor = (triangleColour.*scene.ambientlight+finalC)*0.2;
            e = a;
            rColor = (triangleColour.*scene.ambientlight+finalC).*0.2+ checkReflections(scene,e,dataCoordiantes,light);
end
