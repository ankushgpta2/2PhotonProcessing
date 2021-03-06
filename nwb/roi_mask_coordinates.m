%% Prepare Data to Store in ROI Information Module 
% load the ROI information from the Fall.mat file into MATLAB
load(fullfile(path_to_suite2pfolder_contents, 'Fall.mat'));
load('Fall.mat', 'stat');
load('Fall.mat', 'F');

% first get the center x and y coordinates for each ROI 
center_of_cell_xcoord = [];
center_of_cell_ycoord = [];
ii = 1;

for ii = 1:length(stat)
    center = stat{ii}.med;
    center_of_cell_xcoord(ii) = center(1);
    center_of_cell_ycoord(ii) = center(2);
end 

xycoord_for_centers = vertcat(center_of_cell_xcoord, center_of_cell_ycoord)';

% Make the ROI_masks (Xpix by Ypix Frame with Pixel Location of ROI as Corresponding ROI Number)
ROI_mask = zeros(NpixelsX, NpixelsY);
i = 1;
ii = 1;
for i = 1:length(stat)
    for ii = 1:length(stat{1,i}.xpix)
        if ROI_mask(stat{1,i}.ypix(ii), stat{1,i}.xpix(ii)) == 0
            ROI_mask(stat{1,i}.ypix(ii), stat{1,i}.xpix(ii)) = i;
        else
        end
    end
end

%% store the information above into NWB
id = [1:length(stat)];

ROIs = types.core.PlaneSegmentation(...
    'colnames', {'ROI Information'},...
    'id', types.hdmf_common.ElementIdentifiers('data', id),...
    'description', 'X and Y Pixel Coordinates for Center of Each ROI + ROI Mask Information',...
    'imaging_plane', imagingplane)

% Input the data: (1) ROI_Information under image_mask & (2) Overall_pixel_array under pixel_mask
% in PlaneSegmentation above
ROIs.image_mask = types.hdmf_common.VectorData(...
    'data', ROI_mask,...
    'description', 'Pixel Resolution Location of Each ROI within Xpix by Ypix Frame')

ROIs.pixel_mask = types.hdmf_common.VectorData(...
    'data', xycoord_for_centers,...
    'description', 'X and Y Pixel Coordinates for the Center of Each ROI')

% place the entire planesegmentation above into imagesegmenation
img_seg = types.core.ImageSegmentation();
img_seg.planesegmentation.set('PlaneSegmentation', ROIs)

% create a module under processing for ROIs and place the imagesegmentation
 % into it 
ROI_module = types.core.ProcessingModule( ...
    'description', 'contains ROI information');

ROI_module.nwbdatainterface.set('ImageSegmentation', img_seg);
nwb.processing.set('ROI_mod', ROI_module)
