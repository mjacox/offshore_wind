function data = extract_wea_lat_lon
% Get lat/lon coordinates for wind energy area outlines

% In/out files
dir_in = '~/Dropbox/Documents/Projects/BOEM_wind/data/boem-renewable-energy-shapefiles';
f_ca = sprintf('%s/Offshore_Wind_Leases_outlines',dir_in);
f_or = sprintf('%s/Offshore_Wind_Planning_Areas_outlines',dir_in);

clear data_ca

% Load lease data for California
s = m_shaperead(f_ca);
i1 = find(strcmp(s.fieldnames,'STATE'));
i2 = find(strcmp(s.dbfdata(:,i1),'CA'));
for ii = 1:numel(i2)
    data.ca.crd{ii} = s.ncst{i2(ii),1};
end

% Load planning area data for Oregon
s = m_shaperead(f_or);
i1 = find(strcmp(s.fieldnames,'ADDITIONAL'));
i2 = find(contains(s.dbfdata(:,i1),'Oregon'));
for ii = 1:numel(i2)
    data.or.crd{ii} = s.ncst{i2(ii),1};
end