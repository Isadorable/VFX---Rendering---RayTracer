function scene = simplescene
% SIMPLESCENE Gives a starting scene to base your ray tracer off
%
% The scene will have the following format
% * scene.objects: This contains some number of objects in the scene.
% -€“ object.x: Ignore, gives original points, use transformed points instead.
% -€“ object.p: Transformed points. Each column is a point in 3D space.
% -€“ object.q: Ignore, gives mid-way points before final transformations.
% -€“ object.tri: Each column is a triangle in this object, lists three points in object.p.
% -€“ object.colour: Each column gives the colour of the corresponding triangle. 
%             First three rows are RGB values. 
%             Final three give ratios of base color/reflected colour/refracted colour.
% -€“ object.n: The normal for each triangle.
% -€“ object.vt: These define UV points within a hypothetical texture map (image)
% -€“ object.tri_uvs: For each triangle, gives the points from object.vt which should be used for texturing
% -€“ object.name: A human-readable string describing the shape of the object.
% * scene.numberofobjects: The total number of objects, equal to the length of the object field, for easy reference.
% * scene.imagesize: The resolution for this render, given as [width, height].
% * scene.windowsize: The size of the image plane (in the 3D space), given as [width, height]. 
% * scene.ambientlight: The values to use for the ambient light, RGB.
% * scene.directionallight: Each column contains the location of a light in 3D space.
% * scene.cam: The camera definition to use. Has the following fields:
% -€“ cam.focus: The focal point of the camera in 3D space.
% -€“ cam.focallength: The distance between the focal point and the image plane.
% -€“ cam.{up,right,forward}: The orientation of the camera.
% -€“ cam.coi: The centre of the image plane, computed from the other values for easy reference.

addpath('SceneHelpers')

%% Set up the initial structure of the scene
scene.objects = cell(0); % this will store each object which will have a common format

%% Load shapes
% The shapes are stored in brep format, you can open the files and read them in
% plain text.

% Load the cylinder geometry, and transform it.
cylinder = Brep_fscanf(fopen('cylinder.brep'));
M = Trns_shift( [-1 1 2] )*Trns_scale(  [1,1,2] );
cylinder.p = M*cylinder.p;
cylinder.n = Brep_nrm( cylinder );
cylinder.name = 'cylinder';

% Add the cylinder to the scene
scene.objects{end+1} = cylinder;

% Load the cube, as above.
cube = Brep_fscanf(fopen('cube.brep'));
cube.p = Trns_shift( [2 2.5 0.5] )*cube.p;
cube.p = Trns_scale([2 2 2])*cube.p;
cube.n = Brep_nrm( cube );
cube.vt = [0 0;0 1;1 0;1 1]; % Here are OBJ 'texture' uv coordinates for the cube.
cube.tri_uvs = [1 2 4; 4 3 1; 2 4 3; 3 1 2; 4 3 1; 1 2 4; 2 3 1; 4 3 2; 1 2 4; 4 3 1; 1 2 4; 4 3 1];  
cube.name = 'cube';


% Add the cube to the scene
scene.objects{end+1} = cube;

% Load the plane
plane = Brep_fscanf(fopen('plane.brep'));
plane.p = Trns_scale([15 15 15])*plane.p;
plane.n = Brep_nrm( plane );
plane.name = 'plane';

scene.objects{end+1} = plane;

% Finished adding the objects, count them for easy reference if wanted
scene.numofobjects = length(scene.objects);

% Obviously you can change these at will (or anything else in here)
scene.imagesize = [256; 256];
scene.windowsize = [1; 1]; 
scene.ambientlight = [0.3; 0.3; 0.3];
scene.directionallight = [6 5 3; -1.5 -5 7]';
% scene.directionallight = [5 5 -5; -5 5 -5]';

% A simple perspective projection camera set-up
cam.focus = [-10 0 3]';
cam.focallength = 1;
cam.up = [0 0 1]';
cam.right = [0 -1 0]';
cam.forward = [1 0 0]';
cam.coi = cam.focus+cam.forward*cam.focallength; % centre of (image) window

scene.cam = cam;
