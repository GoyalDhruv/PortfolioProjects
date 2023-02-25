--Cleaning Data in Sql Queries

select *
from PortfolioProject..NashvilleHousing


-- Standardize Date Format

select SaleDate,CONVERT(date,saledate)
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SaleDate=CONVERT(date,SaleDate)

alter table NashvilleHousing
add SaleDate2 date;

update PortfolioProject..NashvilleHousing
set SaleDate2=CONVERT(date,SaleDate)


--Property Address Data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address,City,State)

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)
update PortfolioProject..NashvilleHousing
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)
update PortfolioProject..NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) 



--Split Owner Address

select 
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)
update PortfolioProject..NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)
update PortfolioProject..NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)
update PortfolioProject..NashvilleHousing
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1)


--Change Y and N to YES and NO in "Sold as Vacant" field

select
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing


update PortfolioProject..NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end


--Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (
	Partition by
	ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	order by 
	UniqueID
	) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num>1


--Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate

