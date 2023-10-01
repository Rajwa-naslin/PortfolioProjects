

--1,Cleaning data in sql queries

select * from 
[portfolio project]..NashvilleHousing



--Standardize date format


select SaleDateConverted, convert(Date,SaleDate)
from [portfolio project]..NashvilleHousing

update NashvilleHousing
set SaleDate=convert(Date,SaleDate)


Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=convert(Date,SaleDate)

--populate property address

select *
from [portfolio project]..NashvilleHousing
--where PropertyAddress IS NULL
order by ParcelID

select * 
from [portfolio project]..NashvilleHousing a
join [portfolio project]..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..NashvilleHousing a
join [portfolio project]..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from [portfolio project]..NashvilleHousing a
join [portfolio project]..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual columns (Address,City,State)
select PropertyAddress
from [portfolio project]..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address

from [portfolio project]..NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);


update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) 

select * from 
[portfolio project]..NashvilleHousing



select OwnerAddress
from 
[portfolio project]..NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [portfolio project]..NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);


update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);


update NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from
[portfolio project]..NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field
 select distinct(SoldAsVacant),COUNT(SoldAsVacant)
  from [portfolio project]..NashvilleHousing
  group by SoldAsVacant
  order by 2


  Select SoldAsVacant,
  Case WHEN SoldAsVacant ='y' then 'yes'
       when  SoldAsVacant='n' then 'No'
	   else SoldAsVacant
	   End
  from [portfolio project]..NashvilleHousing

  update NashvilleHousing
  SET SoldAsVacant =  Case WHEN SoldAsVacant ='y' then 'yes'
       when  SoldAsVacant='n' then 'No'
	   else SoldAsVacant
	   End


	   --REMOVE duplicates

	   WITH RowNumCTE as(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			   UniqueID
			   ) row_num

from [portfolio project]..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

select * 
from RowNumCTE
where row_num >1
order by PropertyAddress


--DELETE unused columns

select * 
from [portfolio project]..NashvilleHousing

alter table [portfolio project]..NashvilleHousing
drop column OwnerAddress,TaxDistrict,PropertyAddress

ALTER table [portfolio project]..NashvilleHousing
drop column SaleDate