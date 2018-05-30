clear all

% Define parameters
petroModFolder = 'C:\Program Files\Schlumberger\PetroMod 2016.2\WIN64\bin';
projectFolder = 'C:\Users\malibrah\Desktop\TestPetromod2';

nDim = 1;   % is your model 1D, 2D, or 3D
templateModel = 'M1D';
newModel ='UpdatedModel';

% Open the project
PM = PetroMod(petroModFolder, projectFolder);

% Check the current parameter of the lithology (curves are showed as id)
lithoInfo = PM.Litho.getLithologyInfo('Shale (typical)')

% Get some parameters (works on both scaler and curve)
athysFactor = PM.Litho.getValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)')
heatCapacityCurve = PM.Litho.getValue('Sandstone (clay rich)', 'Heat Capacity Curve')

% Change some parameters (one scaler, and one curve)
PM.Litho.changeValue('Sandstone (clay rich)', 'Athy''s Factor k (depth)', .7);
PM.Litho.changeValue('Sandstone (clay rich)', 'Heat Capacity Curve', [0 10; 10 100]);

% Add and delete lithology
PM.Litho.dublicateLithology('Sandstone (clay rich)', 'Mos Lithology')
PM.Litho.deleteLithology('Mos Lithology');

% Create a lithology mix
PM.Litho.deleteLithology('MosMix');
mixer = LithoMixer('V');
sourceLithologies = {'Sandstone (typical)','Shale (typical)'};
fractions         = [.5, .5];
PM.Litho.mixLitholgies(sourceLithologies, fractions, 'MosMix' , mixer);
lithoInfo = PM.Litho.getLithologyInfo('MosMix');

% Update lithology file 
PM.updateProject();

% Create a new model and simulate
PM.copyModel(templateModel, newModel, nDim);
[output] = PM.simModel(newModel, nDim, true);

% Restore lithology file (does not restore models)
PM.restoreProject();

%%
