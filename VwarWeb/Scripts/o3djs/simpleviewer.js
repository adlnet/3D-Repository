o3djs.require('o3djs.util');
o3djs.require('o3djs.math');
o3djs.require('o3djs.quaternions');
o3djs.require('o3djs.rendergraph');
o3djs.require('o3djs.pack');
o3djs.require('o3djs.arcball');
o3djs.require('o3djs.scene');

var g_root;
var g_o3d;
var g_math;
var g_quaternions;
var g_client;
var g_aball;
var g_thisRot;
var g_lastRot;
var g_pack = null;
var g_mainPack;
var g_viewInfo;
var g_lightPosParam;
var g_loadingElement;
var g_o3dWidth = -1;
var g_o3dHeight = -1;
var g_o3dElement;
var g_finished = false;                     // for selenium
var g_camvec = [5, 5, 5];                   //the offset of the camera from the camera's center of rotation
var g_camcenter = [0, 0, 0];                //the cameras center of rotation
var g_oldx = 0;                             //previous mouse x
var g_oldy = 0;                             //previous mouse y
var g_moving = false;                       //flag to store wheather or not key is down
var g_mouseRotateSensitivity = 1 / 250;     //The sencetivity to the mouse movement
var g_mouseMoveSensitivity = 1 / 350;
var g_defaultRadius = 1;                    //the radius of the bounding sphere
var g_modelCenter = [0, 0, 0];              //center of the model
var g_camcenterGoal = [0, 0, 0];            //goal for the center animation
var g_camvecGoal = [5, 5, 5];               //goal for the cam vec animation
var g_Animating = false;                    //are we animating?
var g_modelSize = 0;                        //the radius of the model
var g_camera = {
    farPlane: 5000,
    nearPlane: 0.1
};

var sidevec =  [1, 0, 0];
var frontvec = [0, 0, 1];
var upvec =    [0, 1, 0];

var g_dragging = false;                     //are we dragging?

function swapFrontUp() {

    var temp = frontvec;
    frontvec = upvec;
    upvec = temp;
    updateCamera();
}

//animate to the front view
function viewFront() {
    g_camvecGoal = [0, 0, g_defaultRadius];
    g_camcenterGoal = g_modelCenter;
    g_Animating = true;
}

//animate to the side view
function viewSide() {
    g_camvecGoal = [g_defaultRadius, 0, 0];
    g_camcenterGoal = g_modelCenter;
    g_Animating = true;
}

//animate to the top view
function viewTop() {
    g_camvecGoal = [.01, g_defaultRadius, .00];
    g_camcenterGoal = g_modelCenter;
    g_Animating = true;
}
//A timer to animate the camera position
function Animate() {
    if (g_Animating == true) {
        //interpolate the camera toward the goal
        g_camvec = g_math.lerpVector(g_camvec, g_camvecGoal, .03);
        g_camcenter = g_math.lerpVector(g_camcenter, g_camcenterGoal, .03);
        updateCamera();

    }
    //repeat 30 times a second
    var t = setTimeout("Animate()", 33);
}

function startDragging(e) {
    g_lastRot = g_thisRot;
    g_dragging = true;
    //Cancel the animated movement;
    //g_Animating = false;
}

//when a key is held, set the moving flag. This prevents rotation and causes mouse motion to be interpreted as movement
function keyDown(e) {
    g_moving = true;
}
//switch back to rotation when the key is released
function keyUp(e) {
    g_moving = false;
}
function drag(e) {

    //if (g_Animating == true)
    //    return;
    //subtract the old mouse position from the new one to get the relative motion
    var relx = e.x - g_oldx;
    var rely = e.y - g_oldy;
    g_oldx = e.x;
    g_oldy = e.y;

    //cancel animation if the user drags or moves the mouse
    if (g_dragging == true || g_moving == true) {
        if (g_Animating == true) {
            g_Animating = false;
            //This is tricky. Something g_math is doing is making camvec a 4d vector
            //which then screws up the math. This kills the 4
            g_camvec = [g_camvec[0], g_camvec[1], g_camvec[2]];
           
        }
    }

    //if we're dragging the mouse, but not holding a key
    if (g_dragging && !g_moving) {
        
        //The up axis - this math won't allow the camera to roll
        var axis = upvec;

        //create a quat based on the relitive mouse movement
        var rot = g_quaternions.axisRotation(axis, -relx * g_mouseRotateSensitivity / g_modelSize * g_math.length(g_camvec));
        var mat = g_quaternions.quaternionToRotation(rot);
        //mul the offset vector by the quat
        g_camvec = g_math.mulVectorMatrix(g_camvec, mat);
        //normalize the camera offset vector
        var camvecnormalized = g_math.normalize(g_camvec);
        //cross with the up vector to get the current side vector
        var sidevec = g_math.cross(axis, camvecnormalized);
        //make a quat to rotate around the new side vector based on the relative mouse y
        var rotside = g_quaternions.axisRotation(sidevec, -rely * g_mouseRotateSensitivity / g_modelSize * g_math.length(g_camvec));
        var matside = g_quaternions.quaternionToRotation(rotside);
        //mul the camera offset vec by the side vector quat
        g_camvec = g_math.mulVectorMatrix(g_camvec, matside);


    }
    //If a key is held, move instead of rotating
    if (g_moving) {
        //tranform the relitive mouse movement from view space to world space, then add to the camera position
        var tempside = g_math.mulVectorScalar(sidevec, -relx * g_mouseMoveSensitivity);
        var tempfront = g_math.mulVectorScalar(frontvec, -rely * g_mouseMoveSensitivity);
        var camoffset = g_math.vecAdd(tempside, tempfront);
        camoffset = g_math.mulVectorScalar(camoffset, g_math.length(g_camvec));
        camoffset = g_math.mulVectorMatrix(camoffset, g_math.inverse(g_viewInfo.drawContext.view));
        g_camcenter = g_math.addVector(g_camcenter, camoffset);
    }
    updateCamera();
}

function stopDragging(e) {
    g_dragging = false;
}

function updateCamera() {
    


    g_camera.eye = g_math.addVector(g_camcenter, g_camvec);
    g_camera.target = g_camcenter;

    g_viewInfo.drawContext.view = g_math.matrix4.lookAt(g_camera.eye,
                                                      g_camera.target,
                                                      upvec);
    g_lightPosParam.value = g_camera.eye;
}

function updateProjection() {
    // Create a perspective projection matrix.
    g_viewInfo.drawContext.projection = g_math.matrix4.perspective(
    g_math.degToRad(45), g_o3dWidth / g_o3dHeight, g_camera.nearPlane,
    g_camera.farPlane);
}

function scrollMe(e) {
    if (e.deltaY) {
        var t = 1;
        if (e.deltaY > 0)
            t = 11 / 12;
        else
            t = 13 / 12;

        if (g_Animating == true) {
            g_Animating = false;
            g_camvec = [g_camvec[0], g_camvec[1], g_camvec[2]];
        }

        g_camvec = g_math.mulVectorScalar(g_camvec, t);



        updateCamera();
    }
}

function enableInput(enable) {
    //document.getElementById("url").disabled = !enable;
    //document.getElementById("load").disabled = !enable;
}

function loadFile(context, path) {
    function callback(pack, parent, exception) {
        enableInput(true);
        if (exception) {
            alert("Could not load: " + path + "\n" + exception);
            g_loadingElement.innerHTML = "loading failed.";
        } else {
            g_loadingElement.innerHTML = "loading finished.";
            // Generate draw elements and setup material draw lists.
            o3djs.pack.preparePack(pack, g_viewInfo);
            var bbox = o3djs.util.getBoundingBoxOfTree(g_client.root);
            g_camera.target = g_math.lerpVector(bbox.minExtent, bbox.maxExtent, 0.5);
            g_modelCenter = g_camera.target;
            g_camcenter = g_modelCenter;
            var diag = g_math.length(g_math.subVector(bbox.maxExtent,
                                                bbox.minExtent));
            g_camera.eye = g_math.addVector(g_camera.target, [0, 0, 1.5 * diag]);
            g_camera.nearPlane = diag / 1000;
            g_camera.farPlane = diag * 10;

            //find the bounding box max size, and fit the camera to that distance
            var camlength = g_math.length(g_math.subVector(bbox.maxExtent, bbox.minExtent));
            g_modelSize = camlength;
            g_camvec = g_math.normalize(g_camvec);
            g_camvec = g_math.mulVectorScalar(g_camvec, camlength * 1.2);
            g_defaultRadius = camlength * 1.2;
            setClientSize();
            updateCamera();
            updateProjection();

            // Manually connect all the materials' lightWorldPos params to the context
            var materials = pack.getObjectsByClassName('o3d.Material');
            for (var m = 0; m < materials.length; ++m) {
                var material = materials[m];
                var param = material.getParam('lightWorldPos');
                if (param) {
                    param.bind(g_lightPosParam);
                }
            }

            g_finished = true;  // for selenium

            // Comment out the next line to dump lots of info.
            if (false) {
                o3djs.dump.dump('---dumping context---\n');
                o3djs.dump.dumpParamObject(context);

                o3djs.dump.dump('---dumping root---\n');
                o3djs.dump.dumpTransformTree(g_client.root);

                o3djs.dump.dump('---dumping render root---\n');
                o3djs.dump.dumpRenderNodeTree(g_client.renderGraphRoot);

                o3djs.dump.dump('---dump g_pack shapes---\n');
                var shapes = pack.getObjectsByClassName('o3d.Shape');
                for (var t = 0; t < shapes.length; t++) {
                    o3djs.dump.dumpShape(shapes[t]);
                }

                o3djs.dump.dump('---dump g_pack materials---\n');
                var materials = pack.getObjectsByClassName('o3d.Material');
                for (var t = 0; t < materials.length; t++) {
                    o3djs.dump.dump(
              '  ' + t + ' : ' + materials[t].className +
              ' : "' + materials[t].name + '"\n');
                    o3djs.dump.dumpParams(materials[t], '    ');
                }

                o3djs.dump.dump('---dump g_pack textures---\n');
                var textures = pack.getObjectsByClassName('o3d.Texture');
                for (var t = 0; t < textures.length; t++) {
                    o3djs.dump.dumpTexture(textures[t]);
                }

                o3djs.dump.dump('---dump g_pack effects---\n');
                var effects = pack.getObjectsByClassName('o3d.Effect');
                for (var t = 0; t < effects.length; t++) {
                    o3djs.dump.dump('  ' + t + ' : ' + effects[t].className +
                  ' : "' + effects[t].name + '"\n');
                    o3djs.dump.dumpParams(effects[t], '    ');
                }
            }
        }
    }

    g_pack = g_client.createPack();

    // Create a new transform for the loaded file
    var parent = g_pack.createObject('Transform');
    parent.parent = g_client.root;
    if (path != null) {
        g_loadingElement.innerHTML = "Loading: " + path;
        enableInput(false);
        try {
            o3djs.scene.loadScene(g_client, g_pack, parent, path, callback);
        } catch (e) {
            enableInput(true);
            g_loadingElement.innerHTML = "loading failed : " + e;
        }
    }

    //Begin animation!
    Animate();
    return parent;
}

function setClientSize() {
    var newWidth = parseInt(g_client.width);
    var newHeight = parseInt(g_client.height);

    if (newWidth != g_o3dWidth || newHeight != g_o3dHeight) {
        g_o3dWidth = newWidth;
        g_o3dHeight = newHeight;

        updateProjection();

        // Sets a new area size for arcball.
        g_aball.setAreaSize(g_o3dWidth, g_o3dHeight);
    }
}

/**
*  Called every frame.
*/
function onRender() {
    // If we don't check the size of the client area every frame we don't get a
    // chance to adjust the perspective matrix fast enough to keep up with the
    // browser resizing us.
    setClientSize();


}

/**
* Creates the client area.
*/
var assetPath;
function init(asset) {
    if (asset) {
        assetPath = asset;
    }
    o3djs.util.makeClients(initStep2);
}

/**
* Initializes O3D and loads the scene into the transform graph.
* @param {Array} clientElements Array of o3d object elements.
*/
var url;
/**
* Initializes O3D and loads the scene into the transform graph.
* @param {Array} clientElements Array of o3d object elements.
*/
function initStep2(clientElements) {
    var path = window.location.href;
    var index = path.lastIndexOf('/');
    path = path.substring(0, index + 1) + assetPath;
    url = path;
    g_loadingElement = document.getElementById('loading');

    g_o3dElement = clientElements[0];
    g_o3d = g_o3dElement.o3d;
    g_math = o3djs.math;
    g_quaternions = o3djs.quaternions;
    g_client = g_o3dElement.client;

    g_mainPack = g_client.createPack();

    // Create the render graph for a view.
    g_viewInfo = o3djs.rendergraph.createBasicView(
      g_mainPack,
      g_client.root,
      g_client.renderGraphRoot,
	  [1, 1, 1, 1]);    //set the clear color to white

    g_lastRot = g_math.matrix4.identity();
    g_thisRot = g_math.matrix4.identity();

    var root = g_client.root;

    g_aball = o3djs.arcball.create(100, 100);
    setClientSize();

    // Set the light at the same position as the camera to create a headlight
    // that illuminates the object straight on.
    var paramObject = g_mainPack.createObject('ParamObject');
    g_lightPosParam = paramObject.createParam('lightWorldPos', 'ParamFloat3');
    g_camera.target = [0, 0, 0];
    g_camera.eye = [0, 5, 5];
    //default position and orientation for the camera
    g_camcenter = [0, 0, 0];
    g_camvec = [5, 5, 5];
    updateCamera();

    doload(url)

    o3djs.event.addEventListener(g_o3dElement, 'mousedown', startDragging);
    o3djs.event.addEventListener(g_o3dElement, 'mousemove', drag);
    o3djs.event.addEventListener(g_o3dElement, 'mouseup', stopDragging);
    o3djs.event.addEventListener(g_o3dElement, 'wheel', scrollMe);
    o3djs.event.addEventListener(g_o3dElement, 'keydown', keyDown);
    o3djs.event.addEventListener(g_o3dElement, 'keyup', keyUp);

    g_client.setRenderCallback(onRender);
}

/**
* Removes any callbacks so they don't get called after the page has unloaded.
*/
function uninit() {
    if (g_client) {
        g_client.cleanup();
    }
}
var assetUrl;
function doload(url) {
    if (url) {
        assetUrl = url;
    }
    if (g_root) {
        g_root.parent = null;
        g_root = null;
    }
    if (g_pack) {
        g_pack.destroy();
        g_pack = null;
    }
    try {
        g_root = loadFile(g_viewInfo.drawContext, assetUrl);
    } catch (ex) {
        alert(ex.message);
    }
}