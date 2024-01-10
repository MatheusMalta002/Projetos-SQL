/*
---------------------------------------------------------------------------------------------------------

-- 1. Padronizando o formato da data

ALTER TABLE Limpeza.dbo.NashvilleHousing
ALTER COLUMN SaleDate date;


[Versão alternativa criando uma nova coluna]

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD SaleDateConverted date;

UPDATE Limpeza.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

---------------------------------------------------------------------------------------------------------

-- 2. Preenchendo os valores nulos na coluna PropertyAddress

-- Executando a consulta abaixo é possível perceber que existem valores  
-- em ParcelID iguais onde alguns tem o valor PropertyAdress e o outros não.

SELECT C1.ParcelID, C1.PropertyAddress, C2.ParcelID, C2.PropertyAddress
FROM Limpeza.dbo.NashvilleHousing C1 INNER JOIN Limpeza.dbo.NashvilleHousing C2 ON (C1.ParcelID = C2.ParcelID)
WHERE  (C1.PropertyAddress IS NULL) AND (C1.[UniqueID ] != C2.[UniqueID ])

-- 1° Se um valor ParcialID tem outra linha com o mesmo parcialID
-- 2° os valores UniqueID dessas linhas são diferentes
-- 3° Uma das linhas com ParcialID iguais posssui o valor NULL em PropertyAddress

-- Isso signifca apenas que a propriedade foi vendida, o dono se altera
-- mas a propriedade permanece no mesmo lugar.

-- Preenchendo os valores NULL com os PropertyAddress das linhas que tem ParcelID iguais

UPDATE C1
SET C1.PropertyAddress = ISNULL(C1.PropertyAddress, C2.PropertyAddress)
FROM Limpeza.dbo.NashvilleHousing C1 
JOIN Limpeza.dbo.NashvilleHousing C2 
	ON (C1.ParcelID = C2.ParcelID) AND (C1.[UniqueID ] != C2.[UniqueID ])
WHERE (C1.PropertyAddress IS NULL) 

---------------------------------------------------------------------------------------------------------

-- 3. Dividindo o endereço em colunas individuais

SELECT SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)) AS 'Address part 1',
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS 'Address part 2'
FROM Limpeza.dbo.NashvilleHousing

-- Criando novas colunas

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE Limpeza.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

-- Adicionando as strings quebradas nas colunas

UPDATE Limpeza.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress))

UPDATE Limpeza.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---------------------------------------------------------------------------------------------------------

Em progresso...

*/




