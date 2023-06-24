/*
CLEANING DATA BY USING SQL
*/

select * from nashhousing

-- 1. Standardizing date format

alter table nashhousing
alter column SaleDate date

select * from nashhousing

-- 2. Populate Property Address Data
-- Find null PropertyAddress
select *
from nashhousing
order by ParcelID

-- Find row with null PropertyAddress that has same ParcelID with other row
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from nashhousing a
join nashhousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Fill the null PropertyAddress
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.propertyAddress)
from nashhousing a
join nashhousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.propertyAddress) 
from nashhousing a
join nashhousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- 3.1 Separate address into 2 columns (Address, State)
select PropertyAddress
from nashhousing

select substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1 ) as Address, substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from nashhousing

-- Add address column
alter table nashhousing
add SplitAddress nvarchar(255);

update nashhousing
set SplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1 )

-- Add city column
alter table nashhousing
add SplitCity nvarchar(255);

update nashhousing
set SplitCity = substring(PropertyAddress, charindex(',', PropertyAddress)+2, len(PropertyAddress))

-- 3.2 Separate owner address into 3 columns (Address, City, State)
select
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from nashhousing

-- Owner Split Address
alter table nashhousing
add OwnerSplitAddress nvarchar(255);

update nashhousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

-- Owner Split City
alter table nashhousing
add OwnerSplitCity nvarchar(255);

update nashhousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

-- Owner Split State
alter table nashhousing
add OwnerSplitState nvarchar(255);

update nashhousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


-- 4. In 'Sold as Vacant' column, there are 4 distinct status : Yes, Y, No, N. Change 'Y' and 'N' to Yes and No
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashhousing
group by SoldAsVacant

select SoldAsVacant,
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from nashhousing

update nashhousing
set SoldAsVacant = case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end


-- 5. Removing duplicate

with row_numCTE as(
select *, row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
								order by UniqueID) row_num

from nashhousing)

--select * from row_numCTE
--where row_num > 1

delete from row_numCTE
where row_num > 1


-- 6. Delete unused columns (Delete Pwner Address and Property Address)
alter table nashhousing
drop column OwnerAddress, PropertyAddress


