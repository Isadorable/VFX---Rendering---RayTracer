function demoRunTime( scene, l, a )
% scene = simplescene;

axis equal

for i = 1:scene.numofobjects
    colour = [0 0 0];
    colour(i) = 1;
    
    plot3(scene.objects{i}.p(1,:),scene.objects{i}.p(2,:),scene.objects{i}.p(3,:),'.','color',colour);
end

plot3(scene.cam.focus(1),scene.cam.focus(2),scene.cam.focus(3),'*k');

topleft = scene.cam.focus + scene.cam.focallength*scene.cam.forward + (scene.windowsize(1)/2)*scene.cam.up - (scene.windowsize(2)/2)*scene.cam.right;
bottomleft = scene.cam.focus + scene.cam.focallength*scene.cam.forward - (scene.windowsize(1)/2)*scene.cam.up - (scene.windowsize(2)/2)*scene.cam.right;
bottomright = scene.cam.focus + scene.cam.focallength*scene.cam.forward - (scene.windowsize(1)/2)*scene.cam.up + (scene.windowsize(2)/2)*scene.cam.right;
topright = scene.cam.focus + scene.cam.focallength*scene.cam.forward + (scene.windowsize(1)/2)*scene.cam.up + (scene.windowsize(2)/2)*scene.cam.right;

points = [topleft , bottomleft, bottomright, topright, topleft];

plot3(points(1,:),points(2,:),points(3,:),'-k');
plot3([l(1,1) a(1,1)],[l(1,1) a(2,1)],[l(1,1) a(3,1)],'--');
plot3(l(1,1),l(2,1),l(3,1),'dr');

plot3(scene.directionallight(1,2),scene.directionallight(2,2),scene.directionallight(3,2),'dg');
for i = 1:4
    f = scene.cam.focus;
    p = points(:,i);
    v = p-f;
    d = f+5*v;
    plot3([f(1) d(1)],[f(2) d(2)],[f(3) d(3)],'--');
end


end

