% 2-D HIO written by Po-Nan Li @ Academia Sinica 2012
% reference: Marchesini et al., 
%  ��X-ray image reconstruction from a diffraction pattern alone,��
%   Phys. Rev. B 68, 140101 (2003).

function [R, Sup, M] = shrinkwrap(Fabs, n, checker, gen, n2, varargin) 

S = fftshift( ifft2(abs(Fabs).^2, 'symmetric') );
S = S > 0.04*max(S(:));


% pre-allocated spaces
R   = zeros( size(Fabs, 1), size(Fabs, 2), gen+1);
Sup = false( size(Fabs, 1), size(Fabs, 2), gen+1);
Sup(:,:,1) = S;

% OSS
if isempty(varargin)
    alpha = [];
else
    alpha = varargin{1};
end

% first run with given support
R(:,:,1) = hio2d(Fabs, S, n, checker, alpha);

% make Gaussian kernel
% fwhm = 8;
% sig = fwhm / 2.355;
sig = 3;
x = (1:size(S,2)) - size(S,2)/2;
y = (1:size(S,1)) - size(S,1)/2;
[X, Y] = meshgrid(x, y);
rad = sqrt(X.^2 + Y.^2);


% shrink-wrap
for g = 1:gen
    G = exp(-(rad./sqrt(2)./sig).^2);
    M = fftshift( ifft2( fft2(R(:,:,g)) .* fft2(G), 'symmetric') );
    Sup(:,:,g+1) = ( M >= 0.05*max(M(:)) );
    R(:,:,g+1) = hio2d(fft2(R(:,:,g)), Sup(:,:,g+1), n2, checker, alpha);
    if sig > 1.5
        sig = sig * 0.99;
    end
end
    