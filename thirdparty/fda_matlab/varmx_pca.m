function  pcarotstr = varmx_pca(pcastr, nharm, nx)
%  VARMX_PCA  Apply varimax rotation to harmonics in a pca.fd object.
%  Arguments:
%  PCASTR ... Struct object returned by PCA_FD.
%  NHARM  ... Number of harmonics to rotate.
%  NX     ... Number of equally spaced points at which harmonics are
%             evaluated.  Default 50.
%  Return:
%  PCAROTSTR ... PCASTR object containing rotated harmonics.

%  last modified 6 April 1999

  if nargin < 3
    nx = 50;
  end
  
  harmfd    = pcastr.harmfd;
  harmcoef  = getcoef(harmfd);
  coefd     = size(harmcoef);
  ndim      = length(coefd);

  scoresd  = size(pcastr.harmscr);
  if nargin < 2
    nharm = scoresd(2);
  end
  if nharm > scoresd(2)
    nharm = scoresd(2);
  end

  basisobj = getbasis(harmfd);
  rangex   = getbasisrange(basisobj);
  x        = linspace(rangex(1), rangex(2), nx);
  harmmat  = eval_fd(harmfd, x);
  %  If fdmat is a 3-D array, stack into a matrix
  if ndim == 3
    harmmatd = size(harmmat);
    harmmat  = permute(harmmat, [1, 3, 2]);
    harmmat  = reshape(harmmat, harmmatd(1) * harmmatd(3), harmmatd(2));
  end
  %  compute rotation matrix for varimax rotation of harmmat
  rotmat = varmx(harmmat);
  %  rotate coefficients and scores
  if ndim == 2
    harmcoef = harmcoef(:,1:nharm);
    harmcoef = harmcoef * rotmat;
  else
    harmcoef = harmcoef(:,1:nharm,:);
    for j = 1:coefd(3)
      harmcoef(:,:,j) = harmcoef(:,:,j) * rotmat;
    end
  end
  pcastr.harmscr  = pcastr.harmscr(:,1:nharm) * rotmat;
  %  modify pcastr object
  harmfd = putcoef(harmfd, harmcoef);

  pcarotstr = pcastr;
  pcarotstr.harmfd  = harmfd;
  pcarotstr.varprop = mean(pcastr.harmscr.^2)./sum(pcastr.eigvals);

