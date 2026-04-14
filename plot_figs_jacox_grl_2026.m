function plot_figs_jacox_grl_2026
% ================================================================
% Plot figures from Jacox et al, GRL, submitted
% 
% M. Jacox
% April 2026
% ================================================================

% Add dependencies
addpath('dependencies')

% Colormaps from cmocean package
global cmaps
cmaps.wind = 'dense';
cmaps.dwind = '-balance';
cmaps.no3 = 'tempo';
cmaps.dno3 = '-curl';
cmaps.bio = 'speed';
cmaps.dbio = 'delta';

% UNCOMMENT TO CALL MANUSCRIPT FIGURES
% ==================
fig1 % Wind changes (maps and climatological time series)
fig2 % CUTI/BEUTI changes
fig3 % Wind/SSH changes
fig4 % SSH/NO3 changes
fig5 % Phyto/zooplankton changes (maps & annual time series)
figs1 % Compare change across runs for multiple variables
figs2 % Change in plankton community
figs3 % Compare changes across seasons

function fig1
% ===============================================
% Maps and time series of wind speed differences

% Load data
load('figure_data_files/fig1.mat','wspd','lon','lat')
load('figure_data_files/coastline.mat','coastline')

% Plotting info
xpos_m = [.035 .34]; % For maps
ypos_m = .09;
width_m = .22;
height_m = .84;
xpos_t = .69; % For time series
ypos_t = [.75 .53 .31 .09];
width_t = .3;
height_t = .18;
iplot = [269 407;276 357;284 320;374 161]; % Points for time series
wind_areas = {'Coos Bay' 'Brookings' 'Humboldt' 'Morro Bay'};
xticks = -128:2:-118;
yticks = 32:2:48;

% Grid resolution (for use with flat shading)
res = lon(2,1)-lon(1,1);

% Colormaps
global cmaps
cmap1 = cmocean(cmaps.wind,20);
cmap1(1,:) = 1;
cmap2 = cmocean(cmaps.dwind,20);
cmap2(10:11,:) = 1;

% Open figure
figure
set(gcf,'color','w','position',[50 50 1100 450])

% Plot wind speed and difference maps
subplot(431),hold on
pcolor(lon-res/2,lat-res/2,mean(wspd(:,:,:,1),3))
title('Baseline')
subplot(432),hold on
pcolor(lon-res/2,lat-res/2,mean(wspd(:,:,:,2)-wspd(:,:,:,1),3))
title('15 MW Difference')

% Plot points used for time series
plot(lon(iplot(:,1),1),lat(1,iplot(:,2)),'ko','markersize',5,'markerfacecolor','w')

% Format maps
% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end
for ii = 1:2
    subplot(4,3,ii)
    shading flat
    set(gca,'tickdir','out','fontsize',9,'color',[.7 .7 .7])
    axis([-129 -117 32 46])
    plot(coastline(:,1),coastline(:,2),'k.','markersize',2)

    % Plot wind energy area outlines
    wea = extract_wea_lat_lon;
    for jj = 1:numel(wea.ca.crd)
        tmp = wea.ca.crd{jj};
        plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1)
    end
    for jj = 1:numel(wea.or.crd)
        tmp = wea.or.crd{jj};
        plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1)
    end
    for jj=1:4
        text(lon(iplot(jj,1),1)-.5,lat(1,iplot(jj,2))+.1,wind_areas{jj},'fontsize',11,'horizontalalignment','right')
    end
    
    if ii==1
        clim([0 10])
        set(gca,'colormap',cmap1,'ytick',yticks,'yticklabel',yticklabs)
        set(gca,'xtick',xticks,'xticklabel',xticklabs)
        cb1 = colorbar;
        set(cb1,'tickdir','out','fontsize',11,'position',...
            [xpos_m(1)+width_m+.01 ypos_m .01 height_m])
        ylabel(cb1,'Wind Speed (m s^{-1})','fontsize',11)
    else
        clim([-1 1])
        set(gca,'ytick',yticks,'yticklabel',[],'colormap',cmap2)
        set(gca,'xtick',xticks,'xticklabel',xticklabs)
        cb2 = colorbar;
        set(cb2,'tickdir','out','fontsize',11,'position',...
            [xpos_m(2)+width_m+.01 ypos_m .01 height_m])
        ylabel(cb2,'\DeltaWind Speed (m s^{-1})','fontsize',11)
    end
    set(gca,'position',[xpos_m(ii) ypos_m width_m height_m])
end

% Plot time series
for ii = 4:-1:1
    subplot(4,3,3*ii),hold on
    h(1) = plot(squeeze(wspd(iplot(ii,1),iplot(ii,2),:,1)),'k','linewidth',1);
    h(2) = plot(squeeze(wspd(iplot(ii,1),iplot(ii,2),:,2)),'k--','linewidth',1);
    h(3) = plot(squeeze(wspd(iplot(ii,1),iplot(ii,2),:,3)),'k:','linewidth',1);
end

% Format time series
for ii=1:4
    subplot(4,3,3*ii)
    set(gca,'tickdir','out','fontsize',11,'xtick',1:12,'xlim',[1 12])
    if ii<4
        set(gca,'xticklabel',[])
    else
        set(gca,'xticklabel',{'J' 'F' 'M' 'A' 'M' 'J' 'J' 'A' 'S' 'O' 'N' 'D'})
    end
    if ii==2
        ylabel('Wind Speed (m s^{-1})','fontsize',11)
    end
    text(.02,.85,wind_areas{ii},'fontsize',11,'units','normalized')
    box on
    if ii==1
        hl = legend(h,'Baseline','15MW','20MW');
        set(hl,'fontsize',11,'location','northoutside','orientation','horizontal')
    end
    set(gca,'position',[xpos_t ypos_t(ii) width_t height_t])
end

function fig2
% ===============================================
% Maps of CUTI and BEUTI differences

% Load data
load('figure_data_files/fig2.mat','lon','lat','cuti_gridded','beuti_gridded')
load('figure_data_files/coastline.mat','coastline')

% Plotting info
clims = [0 1.8;-.3 .3;0 30;-6 6];
clabs = {'CUTI (m^2 s^{-1})' '\DeltaCUTI (m^2 s^{-1})' ...
    'BEUTI (mmol m^{-1} s^{-1})' '\DeltaBEUTI (mmol m^{-1} s^{-1})'};
plabs = {'(a)' '(b)' '(c)' '(d)'};
xpos = [.06 .29 .55 .78];
ypos = [.46 .15];
width = .2;
height = [.52 .26];
axlims = [-125.5 -123.5 39 45;-122.5 -120.5 34 37];
xticks1 = [-125 -124];
xticks2 = [-122 -121];
yticks1 = 39:45;
yticks2 = 34:37;

% Colormaps
global cmaps
cmap1 = cmocean(cmaps.wind,24);
cmap1(1,:) = 1; % Add white
cmap2 = cmocean(cmaps.dwind,24);
cmap2(12:13,:) = 1;
cmap3 = cmocean(cmaps.no3,24);
cmap3(1,:) = 1;
cmap4 = cmocean(cmaps.dno3,24);
cmap4(12:13,:) = 1;

% Grid resolution (for use with flat shading)
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Open figure
figure,set(gcf,'color','w','position',[100 100 750 650])

% Plot
subplot(241),hold on
pcolor(lonp,latp,cuti_gridded(:,:,1))
subplot(242),hold on
pcolor(lonp,latp,mean(cuti_gridded(:,:,2:end),3) - cuti_gridded(:,:,1))
subplot(243),hold on
pcolor(lonp,latp,beuti_gridded(:,:,1))
subplot(244),hold on
pcolor(lonp,latp,mean(beuti_gridded(:,:,2:end),3) - beuti_gridded(:,:,1))
subplot(245),hold on
pcolor(lonp,latp,cuti_gridded(:,:,1))
subplot(246),hold on
pcolor(lonp,latp,mean(cuti_gridded(:,:,2:end),3) - cuti_gridded(:,:,1))
subplot(247),hold on
pcolor(lonp,latp,beuti_gridded(:,:,1))
subplot(248),hold on
pcolor(lonp,latp,mean(beuti_gridded(:,:,2:end),3) - beuti_gridded(:,:,1))

% Make axis labels
for ii = 1:numel(xticks1)
    xticklabs1{ii} = [num2str(-xticks1(ii)) char(176) 'W'];
end
for ii = 1:numel(xticks2)
    xticklabs2{ii} = [num2str(-xticks2(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks1)
    yticklabs1{ii} = [num2str(yticks1(ii)) char(176) 'N'];
end
for ii = 1:numel(yticks2)
    yticklabs2{ii} = [num2str(yticks2(ii)) char(176) 'N'];
end

% Format
nn = 8;
for ii = 2:-1:1
    for jj = 4:-1:1
        subplot(2,4,nn)
        shading flat
        set(gca,'fontsize',9,'tickdir','out','color',[.7 .7 .7])
        plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
        clim(clims(jj,:))
        set(gca,'colormap',eval(['cmap' num2str(jj)]))
        axis(axlims(ii,:))
        if ii==1
            set(gca,'xtick',xticks1,'ytick',yticks1,'xticklabel',xticklabs1)
        else
            set(gca,'xtick',xticks2,'ytick',yticks2,'xticklabel',xticklabs2)
        end
        if jj>1
            set(gca,'yticklabel',[])
        else
            if ii==1
                set(gca,'yticklabel',yticklabs1)
            else
                set(gca,'yticklabel',yticklabs2)
            end
        end
        set(gca,'position',[xpos(jj) ypos(ii) width height(ii)])
        box on
    
        % Plot wind energy area outlines
        if ii==2
            wea = extract_wea_lat_lon;
        end
        for xx = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{xx};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end
        for xx = 1:numel(wea.or.crd)
            tmp = wea.or.crd{xx};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end

        % Plot wea names
        if ii==1 && jj==1
            text(-125.4,43.5,'Coos Bay','fontsize',11)
            text(-125.4,41.8,'Brookings','fontsize',11)
            text(-125.4,40.55,'Humboldt','fontsize',11)
        elseif ii==2&&jj==1
            text(-122.3,35.2,'Morro Bay','fontsize',11)
        end
    
        if ii==2
            cb = colorbar;
            set(cb,'fontsize',11,'tickdir','out','ytick',linspace(clims(jj,1),clims(jj,2),7))
            set(cb,'orientation','horizontal','position',[xpos(jj)+.01 ypos(ii)-.06 width-.02 .015])
            xlabel(cb,clabs{jj},'fontsize',11)
        else
            text(0.03,.97,plabs{jj},'units','normalized','fontsize',11,'fontweight','bold')
        end

        nn = nn-1;
    end
end

function fig3
% ===============================================
% Maps of SSH and wind speed

% Load data
load('figure_data_files/fig3.mat','lon','lat','wspd','ssh')
load('figure_data_files/coastline.mat','coastline')

% Plotting info
xpos = [.035 .315 .655];
ypos = .09;
width = .25;
height = .85;
clims = [0 8;0 8;-1 1];
xticks = -126:2:-116;
yticks = 32:2:44;
clabs = {'' 'Wind speed (m s^{-1})' '\DeltaWind speed (m s^{-1})'};

% Colormaps
global cmaps
cmap1 = cmocean(cmaps.wind,20);
cmap1 = cmap1(1:16,:);
cmap1(1,:) = 1; % Add white
cmap2 = cmocean(cmaps.dwind,24);
cmap2(12:13,:) = 1;

% Grid resolution (for use with flat shading)
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Open figure
figure
set(gcf,'color','w','position',[100 100 1000 400])

% Plot wind speed and difference maps
subplot(131),hold on
pcolor(lonp,latp,wspd(:,:,1))
contour(lon,lat,ssh(:,:,1),-1:.02:1,'k','linewidth',1)
title('Baseline')
subplot(132),hold on
pcolor(lonp,latp,wspd(:,:,1))
contour(lon,lat,mean(ssh(:,:,2:3),3),-1:.02:1,'k','linewidth',1)
title('Turbine')
subplot(133),hold on
pcolor(lonp,latp,mean(wspd(:,:,2:end),3)-wspd(:,:,1))
contour(lon,lat,mean(ssh(:,:,2:end),3)-ssh(:,:,1),.01:.01:1,'k','linewidth',1)
contour(lon,lat,mean(ssh(:,:,2:end),3)-ssh(:,:,1),-1:.01:-.01,'k--','linewidth',1)
title('Difference')

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format
for ii = 1:3
    subplot(1,3,ii)
    shading flat
    set(gca,'tickdir','out','fontsize',9,'color',[.7 .7 .7])
    set(gca,'xtick',xticks,'xticklabel',xticklabs)
    axis([-126 -116 32 44])
    plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
    clim(clims(ii,:))

    if ii<3
        set(gca,'colormap',cmap1)
    else
        set(gca,'colormap',cmap2)
    end
    if ii>1
        set(gca,'ytick',yticks,'yticklabel',[])
        cb = colorbar;
        set(cb,'fontsize',11,'tickdir','out')
        set(cb,'position',[xpos(ii)+width+.01 ypos .015 height])
        ylabel(cb,clabs{ii},'fontsize',11)
    else
        set(gca,'ytick',yticks,'yticklabel',yticklabs)
    end
    if ii==3
        % Plot wind energy area outlines
        wea = extract_wea_lat_lon;
        for jj = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{jj};
            plot(tmp(:,1),tmp(:,2),'k','linewidth',1)
        end
        for jj = 1:numel(wea.or.crd)
            tmp = wea.or.crd{jj};
            plot(tmp(:,1),tmp(:,2),'k','linewidth',1)
        end
    end

    set(gca,'position',[xpos(ii) ypos width height])
end

function fig4
% ===============================================
% Maps of SSH and wind speed

% Load data
load('figure_data_files/fig4.mat','lon','lat','ssh','no3','zsec','lonsec','no3_sec')
load('figure_data_files/coastline.mat','coastline')

% Plotting info
xpos = [.04 .46 .46];
ypos = [.05 .55 .05];
width = [.35 .47 .47];
height = [.92 .42 .42];
clims = [-4 4];
clab = '\Delta[NO_3^-] (mmol m^{-3})';
plotpos = [1 2 4];
trans_col = [0 0 1];
xticks = -126:2:-116;
yticks = 32:2:44;
latbnds = [34.6 33.2];
lonbnds = [-125 -120];
depthbnds = [0 200];

% Colormaps
global cmaps
cmap = cmocean(cmaps.dno3,24);
cmap(12:13,:) = 1;

% Grid resolution
res = lon(2,1)-lon(1,1);

% Open figure
figure
set(gcf,'color','w','position',[100 100 1000 500])

% Plot no3/ssh map
subplot(221),hold on
pcolor(lon-res/2,lat-res/2,mean(no3(:,:,2:end),3)-no3(:,:,1))
contour(lon,lat,mean(ssh(:,:,2:end),3)-ssh(:,:,1),.01:.01:1,'k','linewidth',1)
contour(lon,lat,mean(ssh(:,:,2:end),3)-ssh(:,:,1),-1:.01:-.01,'k:','linewidth',1)

% Plot no3 sections w/ mean no3 contours
subplot(222),hold on
pcolor(lonsec,zsec,mean(no3_sec(:,:,2:3,1),3)-no3_sec(:,:,1,1))
[c,h] = contour(lonsec,zsec,no3_sec(:,:,1,1),[1 5:5:40],'k');
clabel(c,h,'fontweight','bold')
contour(lonsec,zsec,mean(no3_sec(:,:,2:3,1),3),[1 5:5:40],'k--')
subplot(224),hold on
pcolor(lonsec,zsec,mean(no3_sec(:,:,2:3,2),3)-no3_sec(:,:,1,2))
[c,h] = contour(lonsec,zsec,no3_sec(:,:,1,2),[1 5:5:40],'k');
clabel(c,h,'fontweight','bold')
contour(lonsec,zsec,mean(no3_sec(:,:,2:3,2),3),[1 5:5:40],'k--')

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format
for ii = 1:3
    subplot(2,2,plotpos(ii))
    shading flat
    clim(clims)
    set(gca,'colormap',cmap)
    box on
    set(gca,'tickdir','out','fontsize',9)
    
    if ii==1
        axis([-126 -116 32 44])
        set(gca,'xtick',xticks,'xticklabel',xticklabs,'ytick',yticks,'yticklabel',yticklabs)
        plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
        set(gca,'color',[.7 .7 .7])
        plot(lonbnds,[latbnds(1) latbnds(1)],'color',trans_col,'linewidth',2)
        plot(lonbnds,[latbnds(2) latbnds(2)],':','color',trans_col,'linewidth',2)
        
        % Plot wind energy area outlines
        wea = extract_wea_lat_lon;
        for jj = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{jj};
            plot(tmp(:,1),tmp(:,2),'k','linewidth',1)
        end
        for jj = 1:numel(wea.or.crd)
            tmp = wea.or.crd{jj};
            plot(tmp(:,1),tmp(:,2),'k','linewidth',1)
        end
    else
        axis([lonbnds depthbnds])
        set(gca,'ydir','reverse','color','k','xtick',lonbnds(1):lonbnds(2))
        ylabel('Depth (m)')
        if ii==2
            plot(lonbnds,[1 1],'color',trans_col,'linewidth',2)
        else
            plot(lonbnds,[1 1],'w','linewidth',2)
            plot(lonbnds,[1 1],':','color',trans_col,'linewidth',2)
        end
    end
    if ii==2
        set(gca,'xtick',xticks,'xticklabel',[])
    end
    if ii==3
        cb = colorbar;
        set(cb,'fontsize',11,'tickdir','out')
        set(gca,'xtick',xticks,'xticklabel',xticklabs)
        set(cb,'position',[xpos(ii)+width(ii)+.01 ypos(ii) .01 height(1)])
        ylabel(cb,clab,'fontsize',11)
    end
    set(gca,'position',[xpos(ii) ypos(ii) width(ii) height(ii)])
end

function fig5
% ===============================================
% Phyto/zooplankton changes (maps & annual time series)

% Load data
load('figure_data_files/fig5.mat','lon','lat','years','phyto_mean','zoo_mean','phyto_reg_ann','zoo_reg_ann')
load('figure_data_files/coastline.mat','coastline')

% Open figure
figure,set(gcf,'color','w','position',[100 100 900 600])

% Adjust lat/lon for pcolor with shading flat
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Plotting info for maps
clims = [0 60;-20 20;0 60;-20 20];
clabs = {'' '' 'Biomass (mmol N m^{-2})' '\DeltaBiomass (%)'};
titles = {'Phytoplankton' '' 'Zooplankton' ''};
xpos = [.04 .245 .04 .245];
ypos = [.58 .58 .135 .135];
width = .18;
height = .39;
xticks = -124:4:-116;
yticks = 32:2:44;
axlims = [1995 2020 5 25;1995 2020 20 55];
reg = [-124.3 -122.3 34 36;-122.6 -120.6 32 34]; % Regions to average over

% Colormap
global cmaps
cmap1 = cmocean(cmaps.bio,12);
cmap1(1,:) = 1;
cmap2 = cmocean(cmaps.dbio,12);
cmap2(6:7,:) = 1;
regcol = [0 .5 0;0 0 .7];

% Plot maps
subplot(241),hold on
pcolor(lonp,latp,phyto_mean(:,:,1))
subplot(242),hold on
pcolor(lonp,latp,100*(mean(phyto_mean(:,:,2:end),3)-phyto_mean(:,:,1))./phyto_mean(:,:,1))
subplot(245),hold on
pcolor(lonp,latp,zoo_mean(:,:,1))
subplot(246),hold on
pcolor(lonp,latp,100*(mean(zoo_mean(:,:,2:end),3)-zoo_mean(:,:,1))./zoo_mean(:,:,1))

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format maps
nplot = [1 2 5 6];
for ii = 1:4
    subplot(2,4,nplot(ii))
    shading flat
    set(gca,'fontsize',9,'tickdir','out','color',[.7 .7 .7])
    plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
    clim(clims(ii,:))
    if ii==1||ii==3
        set(gca,'colormap',cmap1)
        text(1+(xpos(2)-xpos(1)-width)/2/width,1.04,titles{ii},'fontsize',12,'fontweight','bold','horizontalalignment','center','units','normalized')
    else
        set(gca,'colormap',cmap2)
        % Plot regions for averaging
        rectangle('position',[reg(1,1) reg(1,3) reg(1,2)-reg(1,1) reg(1,4)-reg(1,3)],'linewidth',1.5,'edgecolor',regcol(1,:))
        rectangle('position',[reg(2,1) reg(2,3) reg(2,2)-reg(2,1) reg(2,4)-reg(2,3)],'linewidth',1.5,'edgecolor',regcol(2,:))
    end
    box on
    axis([-126 -116 32 44])
    if ii==2||ii==4
        set(gca,'ytick',yticks,'yticklabel',[])
    else
        set(gca,'ytick',yticks,'yticklabel',yticklabs)
    end
    if ii<3
        set(gca,'xtick',xticks,'xticklabel',[])
    else
        xtickangle(0)
        set(gca,'xtick',xticks,'xticklabel',xticklabs)
    end
    set(gca,'position',[xpos(ii) ypos(ii) width height])
    if ii==3
        cb = colorbar;
        set(cb,'fontsize',11,'tickdir','out','ytick',linspace(clims(ii,1),clims(ii,2),5))
        xlabel(cb,clabs{ii},'fontsize',11)
        cb.Ruler.TickLabelRotation = 0;
        set(cb,'orientation','horizontal','position',[xpos(ii)+.01 ypos(ii)-.06 width-.02 .015])
    elseif ii==4
        cb = colorbar;
        set(cb,'fontsize',11,'tickdir','out','ytick',linspace(clims(ii,1),clims(ii,2),5))
        xlabel(cb,clabs{ii},'fontsize',11)
        cb.Ruler.TickLabelRotation = 0;
        set(cb,'orientation','horizontal','position',[xpos(ii)+.01 ypos(ii)-.06 width-.02 .015])
    end

    % Plot wind energy area outlines
    if ii==1
        wea = extract_wea_lat_lon;
    end
    for jj = 1:numel(wea.ca.crd)
        tmp = wea.ca.crd{jj};
        plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
    end
    for jj = 1:numel(wea.or.crd)
        tmp = wea.or.crd{jj};
        plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
    end
    box on
end

% Phytoplankton
subplot(2,4,3),hold on
plot(years,phyto_reg_ann(:,1,1),'-o','color',regcol(1,:),'markerfacecolor',regcol(1,:),'linewidth',1)
plot(years,mean(phyto_reg_ann(:,1,2:end),3),'--o','color',regcol(1,:),'markerfacecolor','w','linewidth',1)
plot(years,phyto_reg_ann(:,2,1),'-o','color',regcol(2,:),'markerfacecolor',regcol(2,:),'linewidth',1)
plot(years,mean(phyto_reg_ann(:,2,2:end),3),'--o','color',regcol(2,:),'markerfacecolor','w','linewidth',1)
set(gca,'position',[xpos(2)+width+.075 ypos(1) .48 height])
set(gca,'xticklabel',[],'fontsize',10,'tickdir','out','xlim',[1996 2020])
ylabel('Biomass (mmol N m^{-2})')
axis(axlims(1,:))
box on

% Legend
h(1) = plot([0 1],[0 1],'-ko','linewidth',1,'markerfacecolor','k');
h(2) = plot([0 1],[0 1],'--ko','linewidth',1,'markerfacecolor','w');
hl = legend(h,'Baseline','Turbines');
set(hl,'fontsize',11,'location','southeast')

% Zooplankton
subplot(2,4,7),hold on
plot(years,zoo_reg_ann(:,1,1),'-o','color',regcol(1,:),'markerfacecolor',regcol(1,:),'linewidth',1)
plot(years,mean(zoo_reg_ann(:,1,2:end),3),'--o','color',regcol(1,:),'markerfacecolor','w','linewidth',1)
plot(years,zoo_reg_ann(:,2,1),'-o','color',regcol(2,:),'markerfacecolor',regcol(2,:),'linewidth',1)
plot(years,mean(zoo_reg_ann(:,2,2:end),3),'--o','color',regcol(2,:),'markerfacecolor','w','linewidth',1)
set(gca,'position',[xpos(2)+width+.075 ypos(3) .48 height])
set(gca,'fontsize',10,'tickdir','out','xlim',[1996 2020])
ylabel('Biomass (mmol N m^{-2})')
xlabel('Year')
axis(axlims(2,:))
box on

function figs1
% ===============================================
% Maps of difference for all scenarios

% Load data
load('figure_data_files/figs1.mat','lon','lat','no3','ssh','cuti_gridded','beuti_gridded','phyto_mean','zoo_mean')
load('figure_data_files/coastline.mat','coastline')

% Open figure
figure,set(gcf,'color','w','position',[100 100 650 850])

% Adjust lat/lon for pcolor with shading flat
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Plotting info
xpos = [.055 .27 .485 .7];
ypos = [.76 .52 .28 .04];
width = .185;
height = .205;
clims = [-.4 .4;-4 4;-20 20;-20 20];
clabs = {'\DeltaCUTI (m^2 s^{-1})' '\Delta[NO_3^-] (mmol m^{-3})'...
    '\DeltaPhytoplankton (%)' '\DeltaZooplankton (%)'};
xticks = -124:4:-116;
yticks = 32:2:44;
titles = {'15 MW' '15 MW rerun' '20 MW' 'Mean'};

% Colormaps
global cmaps
cmap(1,:,:) = cmocean(cmaps.dwind,12);
cmap(1,6:7,:) = 1;
cmap(2,:,:) = cmocean(cmaps.dno3,12);
cmap(2,6:7,:) = 1;
cmap(3,:,:) = cmocean(cmaps.dbio,12);
cmap(3,6:7,:) = 1;
cmap(4,:,:) = cmap(3,:,:);

% Plot differences for each run
for ii=1:3
    subplot(4,4,ii),hold on
    pcolor(lonp,latp,cuti_gridded(:,:,ii+1)-cuti_gridded(:,:,1));
    subplot(4,4,ii+4),hold on
    pcolor(lonp,latp,no3(:,:,ii+1)-no3(:,:,1));
    contour(lonp,latp,ssh(:,:,ii+1)-ssh(:,:,1),.01:.01:1,'k','linewidth',1)
    contour(lonp,latp,ssh(:,:,ii+1)-ssh(:,:,1),-1:.01:-.01,'k--','linewidth',1)
    subplot(4,4,ii+8),hold on
    pcolor(lonp,latp,100*(phyto_mean(:,:,ii+1)-phyto_mean(:,:,1))./phyto_mean(:,:,1));
    subplot(4,4,ii+12),hold on
    pcolor(lonp,latp,100*(zoo_mean(:,:,ii+1)-zoo_mean(:,:,1))./zoo_mean(:,:,1));
end

% Plot mean of differences across runs
subplot(4,4,4),hold on
pcolor(lonp,latp,mean(cuti_gridded(:,:,2:4),3)-cuti_gridded(:,:,1));
subplot(4,4,8),hold on
pcolor(lonp,latp,mean(no3(:,:,2:4),3)-no3(:,:,1));
contour(lonp,latp,mean(ssh(:,:,2:4),3)-ssh(:,:,1),.01:.01:1,'k','linewidth',1)
contour(lonp,latp,mean(ssh(:,:,2:4),3)-ssh(:,:,1),-1:.01:-.01,'k--','linewidth',1)
subplot(4,4,12),hold on
pcolor(lonp,latp,100*(mean(phyto_mean(:,:,2:4),3)-phyto_mean(:,:,1))./phyto_mean(:,:,1));
subplot(4,4,16),hold on
pcolor(lonp,latp,100*(mean(zoo_mean(:,:,2:4),3)-zoo_mean(:,:,1))./zoo_mean(:,:,1));

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format
nn = 1;
for ii = 1:4
    for jj = 1:4
        subplot(4,4,nn)
        shading flat
        set(gca,'fontsize',9,'tickdir','out','color',[.7 .7 .7])
        plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
        clim(clims(ii,:))
        set(gca,'colormap',squeeze(cmap(ii,:,:)))
        box on
        axis([-126 -116 32 44])
        if jj>1
            set(gca,'ytick',yticks,'yticklabel',[])
        else
            set(gca,'ytick',yticks,'yticklabel',yticklabs)
        end
        if ii<4
            set(gca,'xtick',xticks,'xticklabel',[])
        else
            set(gca,'xtick',xticks,'xticklabel',xticklabs)
        end
        if ii==1
            title(titles{jj},'fontsize',11)
        end
        set(gca,'position',[xpos(jj) ypos(ii) width height])
        if jj==4
            cb = colorbar;
            set(cb,'fontsize',11,'tickdir','out','ytick',linspace(clims(ii,1),clims(ii,2),5))
            ylabel(cb,clabs{ii},'fontsize',11)
            set(cb,'position',[xpos(jj)+width+.01 ypos(ii) .02 height])
        end

        % Plot wind energy area outlines
        if nn==1
            wea = extract_wea_lat_lon;
        end
        for jj = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{jj};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end
        for jj = 1:numel(wea.or.crd)
            tmp = wea.or.crd{jj};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end

        nn = nn+1;
    end
end

function figs2
% ===============================================
% Plankton size class changes

% Load data
load('figure_data_files/figs2.mat','lon','lat','ratio')
load('figure_data_files/coastline.mat','coastline')

% Open figure
figure,set(gcf,'color','w','position',[100 100 800 400])

% Adjust lat/lon for pcolor with shading flat
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Plotting info
xpos = [.04 .21 .41 .58 .75];
ypos = [.54 .08];
width = .15;
height = .4;
clims = [0 1;-.1 .1];
clabs = {'Fraction' '\DeltaFraction'};
titles = {'Nanophytoplankton' 'Diatoms' 'Microzooplankton' ...
    'Mesozooplankton' 'Predatory zooplankton'};
xticks = -124:4:-116;
yticks = 32:2:44;

% Colormaps
global cmaps
cmap(:,:,1) = cmocean(cmaps.bio,20);
cmap(1,:,1) = 1;
cmap(:,:,2) = cmocean(cmaps.dbio,20);
cmap(10:11,:,2) = 1;

% Plot mean and difference for each plankton group
for ii=1:5
    subplot(2,5,ii),hold on
    pcolor(lonp,latp,ratio(:,:,1,ii));
    subplot(2,5,ii+5),hold on
    pcolor(lonp,latp,mean(ratio(:,:,2:end,ii),3)-ratio(:,:,1,ii));
end

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format
nn = 1;
for ii = 1:2
    for jj = 1:5
        subplot(2,5,nn)
        shading flat
        set(gca,'fontsize',9,'tickdir','out','color',[.7 .7 .7])
        plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
        clim(clims(ii,:))
        set(gca,'colormap',cmap(:,:,ii))
        box on
        axis([-126 -116 32 44])
        if jj>1
            set(gca,'ytick',yticks,'yticklabel',[])
        else
            set(gca,'ytick',yticks,'yticklabel',yticklabs)
        end
        if ii==1
            set(gca,'xtick',xticks,'xticklabel',[])
            title(titles{jj},'fontsize',10)
        else
            set(gca,'xtick',xticks,'xticklabel',xticklabs)
        end
        set(gca,'position',[xpos(jj) ypos(ii) width height])
        if jj==5
            cb = colorbar;
            set(cb,'fontsize',10,'tickdir','out','ytick',linspace(clims(ii,1),clims(ii,2),5))
            ylabel(cb,clabs{ii},'fontsize',10)
            set(cb,'position',[xpos(jj)+width+.01 ypos(ii) .02 height])
        end

        % Plot wind energy area outlines
        if nn==1
            wea = extract_wea_lat_lon;
        end
        for kk = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{kk};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end
        for kk = 1:numel(wea.or.crd)
            tmp = wea.or.crd{kk};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end

        nn = nn+1;
    end
end

function figs3
% ===============================================
% Maps of difference for multiple seasons

% Load data
load('figure_data_files/figs3.mat','lon','lat','cuti_gridded','ssh','no3','phyto_mean','zoo_mean')
load('figure_data_files/coastline.mat','coastline')

% Open figure
figure,set(gcf,'color','w','position',[100 100 350 850])

% Adjust lat/lon for pcolor with shading flat
res = lon(2,1)-lon(1,1);
lonp = lon-res/2;
latp = lat-res/2;

% Plotting info
mbnds = [4 7;8 3];
clims = [-.4 .4;-4 4;-20 20;-20 20];
clabs = {'\DeltaCUTI (m^2 s^{-1})' '\Delta[NO_3^-] (mmol m^{-3})'...
    '\DeltaPhytoplankton (%)' '\DeltaZooplankton (%)'};
titles = {'Apr-Jul' 'Aug-Mar'};
xpos = [.09 .48];
ypos = [.76 .52 .28 .04];
width = .35;
height = .205;
xticks = -124:4:-116;
yticks = 32:2:44;

% Colormaps
global cmaps
cmap(1,:,:) = cmocean(cmaps.dwind,12);
cmap(1,6:7,:) = 1;
cmap(2,:,:) = cmocean(cmaps.dno3,12);
cmap(2,6:7,:) = 1;
cmap(3,:,:) = cmocean(cmaps.dbio,12);
cmap(3,6:7,:) = 1;
cmap(4,:,:) = cmap(3,:,:);

% Plot mean of differences across runs
subplot(4,2,1),hold on
pcolor(lonp,latp,mean(cuti_gridded(:,:,1,2:end),4)-cuti_gridded(:,:,1,1))
subplot(4,2,2),hold on
pcolor(lonp,latp,mean(cuti_gridded(:,:,2,2:end),4)-cuti_gridded(:,:,2,1))
subplot(4,2,3),hold on
pcolor(lonp,latp,mean(no3(:,:,1,2:end),4)-no3(:,:,1,1))
contour(lonp,latp,mean(ssh(:,:,1,2:end),4)-ssh(:,:,1,1),.01:.01:1,'k','linewidth',1)
contour(lonp,latp,mean(ssh(:,:,1,2:end),4)-ssh(:,:,1,1),-1:.01:-.01,'k--','linewidth',1)
subplot(4,2,4),hold on
pcolor(lonp,latp,mean(no3(:,:,2,2:end),4)-no3(:,:,2,1))
contour(lonp,latp,mean(ssh(:,:,2,2:end),4)-ssh(:,:,2,1),.01:.01:1,'k','linewidth',1)
contour(lonp,latp,mean(ssh(:,:,2,2:end),4)-ssh(:,:,2,1),-1:.01:-.01,'k--','linewidth',1)
subplot(4,2,5),hold on
pcolor(lonp,latp,100*(mean(phyto_mean(:,:,1,2:end),4)-phyto_mean(:,:,1,1))./phyto_mean(:,:,1,1));
subplot(4,2,6),hold on
pcolor(lonp,latp,100*(mean(phyto_mean(:,:,2,2:end),4)-phyto_mean(:,:,2,1))./phyto_mean(:,:,2,1));
subplot(4,2,7),hold on
pcolor(lonp,latp,100*(mean(zoo_mean(:,:,1,2:end),4)-zoo_mean(:,:,1,1))./zoo_mean(:,:,1,1));
subplot(4,2,8),hold on
pcolor(lonp,latp,100*(mean(zoo_mean(:,:,2,2:end),4)-zoo_mean(:,:,2,1))./zoo_mean(:,:,2,1));

% Make axes labels
for ii = 1:numel(xticks)
    xticklabs{ii} = [num2str(-xticks(ii)) char(176) 'W'];
end
for ii = 1:numel(yticks)
    yticklabs{ii} = [num2str(yticks(ii)) char(176) 'N'];
end

% Format
nn = 1;
for ii = 1:4
    for jj = 1:2
        subplot(4,2,nn)
        shading flat
        set(gca,'fontsize',9,'tickdir','out','color',[.7 .7 .7])
        plot(coastline(:,1),coastline(:,2),'k.','markersize',2)
        clim(clims(ii,:))
        set(gca,'colormap',squeeze(cmap(ii,:,:)))
        box on
        axis([-126 -116 32 44])
        if jj>1
            set(gca,'ytick',yticks,'yticklabel',[])
        else
            set(gca,'ytick',yticks,'yticklabel',yticklabs)
        end
        if ii<4
            set(gca,'xtick',xticks,'xticklabel',[])
        else
            set(gca,'xtick',xticks,'xticklabel',xticklabs)
        end
        if ii==1
            title(titles{jj},'fontsize',11)
        end
        set(gca,'position',[xpos(jj) ypos(ii) width height])

        if jj==2
            cb = colorbar;
            set(cb,'fontsize',10,'tickdir','out','ytick',linspace(clims(ii,1),clims(ii,2),5))
            ylabel(cb,clabs{ii})
            set(cb,'position',[xpos(jj)+width+.01 ypos(ii) .02 height])
        end     

        % Plot wind energy area outlines
        if nn==1
            wea = extract_wea_lat_lon;
        end
        for jj = 1:numel(wea.ca.crd)
            tmp = wea.ca.crd{jj};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end
        for jj = 1:numel(wea.or.crd)
            tmp = wea.or.crd{jj};
            plot(tmp(:,1),tmp(:,2),'color',[0 0 0],'linewidth',1.5)
        end

        nn = nn+1;
    end
end
