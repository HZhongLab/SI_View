function [quick_info] = jbm_quickInfo(header)

quick_info.zoom = header.acq.zoomFactor;
quick_info.binx = header.acq.pixelsPerLine;
quick_info.biny = header.acq.linesPerFrame;
quick_info.zstep = header.acq.zStepSize;
quick_info.lp = header.init.eom.maxPower;

end

