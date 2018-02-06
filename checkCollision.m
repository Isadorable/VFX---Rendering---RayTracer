function lightStatus = checkCollision(scene,light,dataCoordiantes,e)
lightStatus = 0;
n = dataCoordiantes{1,1};
a = dataCoordiantes{1,2};
vLight = (light-a)/norm(light-a);

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
                t = dot(p1-a,n)/dot(n,vLight);
%         t = dot(p1-e,n)/dot(n,ray);
        if t > 0
            %a is intersection point of the ray with the triangles
            a1 = a+t*vLight;
%             a1 = a+t*ray;
            
            %check if a is within the current triangle
            r1 = dot(cross((p2-p1)/norm(p2-p1),(a1-p1)/norm(a1-p1)),n);
            r2 = dot(cross((p3-p2)/norm(p3-p2),(a1-p2)/norm(a1-p2)),n);
            r3 = dot(cross((p1-p3)/norm(p1-p3),(a1-p3)/norm(a1-p3)),n);
            %if so, for every pixel i,j we save the value of the
            %smallest t which corresponds to the distance of the
            %closest triangle respect to the camera position
            
            d = sqrt((a1(1,:)-a(1,:))^2+(a1(2,:)-a(2,:))^2+(a1(3,:)-a(3,:))^2);
            if(r1 >= 0 && r2 >= 0 && r3 >= 0 && d > 0.1);                
                lightStatus = 1;
                return
            end
        end
    end
end

