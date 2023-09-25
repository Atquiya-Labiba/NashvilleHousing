--View Nashville Housing Table
select * from Portfolio_project.dbo.[NashvilleHousingData] 

--SalePrice Update
select * from Portfolio_project.dbo.[NashvilleHousingData] where SalePrice <>'$'
select PARSENAME(REPLACE(SalePrice,'$','.'),1) as 'Dollar'
from Portfolio_project.dbo.[NashvilleHousingData] 

alter table NashvilleHousingData
add SalePriceSplit Nvarchar(255)

update NashvilleHousingData
set SalePriceSplit=PARSENAME(REPLACE(SalePrice,'$','.'),1)


--Alter Table With Standardize SaleDate
alter table [NashvilleHousingData]  alter column SaleDate Date

--Populate Property Address Data
--Checking Null Values
select PropertyAddress from Portfolio_project.dbo.[NashvilleHousingData] 
where PropertyAddress is null

select n.ParcelID, n.PropertyAddress, nn.ParcelID, nn.PropertyAddress, ISNULL(n.PropertyAddress,nn.PropertyAddress)
from Portfolio_project.dbo.[NashvilleHousingData] n
JOIN Portfolio_project.dbo.[NashvilleHousingData] nn
	on n.ParcelID = nn.ParcelID
	AND n.[UniqueID ] <> nn.[UniqueID ]
where n.PropertyAddress is null

--Update Null Property Address
update n
set PropertyAddress= ISNULL(n.PropertyAddress,nn.PropertyAddress)
from Portfolio_project.dbo.[NashvilleHousingData] n
JOIN Portfolio_project.dbo.[NashvilleHousingData] nn
	on n.ParcelID = nn.ParcelID
	AND n.[UniqueID ] <> nn.[UniqueID ]
where n.PropertyAddress is null

--Breaking Down the PropertyAddress into Address,City
select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as 'Address',
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as 'City' 
from Portfolio_project.dbo.[NashvilleHousingData] 

--Alter Table with broken down address
alter table NashvilleHousingData
add PropertySplitAddress Nvarchar(255)

update NashvilleHousingData 
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

alter table NashvilleHousingData
add PropertyCityAddress Nvarchar(255)

update NashvilleHousingData 
set PropertyCityAddress = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Check whether OwnerAddress containes null value
select OwnerAddress from Portfolio_project.dbo.[NashvilleHousingData] 
where PropertyAddress is null

--Split OwnerAddress into Address,City,State
select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as 'Address',PARSENAME(REPLACE(OwnerAddress,',','.'),2) as 'City',PARSENAME(REPLACE(OwnerAddress,',','.'),1) as 'State' 
from Portfolio_project.dbo.[NashvilleHousingData] 

alter table NashvilleHousingData
add OwnerSplitAddress Nvarchar(255)

update NashvilleHousingData 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table NashvilleHousingData
add OwnerCity Nvarchar(255)

update NashvilleHousingData 
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table NashvilleHousingData
add OwnerState Nvarchar(255)

update NashvilleHousingData 
set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Check variations in SoldAsVacant
select distinct SoldAsVacant 
from Portfolio_project.dbo.[NashvilleHousingData] 

select SoldAsVacant,
	case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from Portfolio_project.dbo.[NashvilleHousingData]

update NashvilleHousingData
set SoldAsVacant=case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

--Remove Duplicates
with DupCTE AS(
select *, row_number() over( partition by
ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
ORDER BY UniqueID) row_num
from Portfolio_project.dbo.NashvilleHousingData
)
select * from DupCTE 
where row_num>1



