int glbVarInt = 800;
string glbVarString = "value";
float glbVarFloat = 99.34323;
any glbVarAny = 88343;

float glbVarFloatChange = 99;

float glbVarFloat1 = glbVarFloat;

function getGlobalVars() (int, string, float, any) {
return glbVarInt, glbVarString, glbVarFloat, glbVarAny;
}

function accessGlobalVar() (int) {
return glbVarInt + (int)glbVarAny;
}

function changeGlobalVar(int addVal) (float) {
glbVarFloatChange = 77 + addVal;
float value = glbVarFloatChange;
return value;
}

function getGlobalFloatVar() (float) {
changeGlobalVar(3);
return glbVarFloatChange;
}

function getGlobalVarFloat1()(float) {
return glbVarFloat1;
}