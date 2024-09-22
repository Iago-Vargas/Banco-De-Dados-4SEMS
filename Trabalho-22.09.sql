--1 Crie uma producure que permita inserir uma nova categoria na tabela ''Categoria''

CREATE PROCEDURE InserirCategoria
    @Nome NVARCHAR(100),  -- Parâmetro para o nome da categoria
    @Descricao NVARCHAR(255)  -- Parâmetro para a descrição da categoria
AS
BEGIN
    -- Verifica se o nome da categoria já existe
    IF EXISTS (SELECT 1 FROM Categoria WHERE Nome = @Nome)
    BEGIN
        RAISERROR('Categoria já existe.', 16, 1);  -- Lança um erro se a categoria existir
        RETURN;  -- Encerra a execução da procedure
    END

    -- Insere a nova categoria
    INSERT INTO Categoria (Nome, Descricao)
    VALUES (@Nome, @Descricao);
END;

--2 Crie uma procedure para atualizar os detalhes de um livro (por exemplo, titulo, ano) pelo ISBN
CREATE PROCEDURE AtualizarLivro
    @ISBN NVARCHAR(20),        -- Parâmetro para o ISBN do livro
    @Titulo NVARCHAR(255),     -- Parâmetro para o título do livro
    @Ano INT                   -- Parâmetro para o ano de publicação do livro
AS
BEGIN
    -- Verifica se o livro existe
    IF NOT EXISTS (SELECT 1 FROM Livro WHERE ISBN = @ISBN)
    BEGIN
        RAISERROR('Livro não encontrado.', 16, 1);  -- Lança um erro se o livro não existir
        RETURN;  -- Encerra a execução da procedure
    END

    -- Atualiza os detalhes do livro
    UPDATE Livro
    SET Titulo = @Titulo,       -- Atualiza o título
        Ano = @Ano              -- Atualiza o ano
    WHERE ISBN = @ISBN;         -- Filtra pelo ISBN
END;
EXEC AtualizarLivro 
    @ISBN = '333',         -- ISBN do livro que você deseja atualizar
    @Titulo = 'Matue', -- Aqui você coloca o novo título
    @Ano = 2024;                  -- Ano de publicação do livro

--3 (12) Desenvolva uma procedure para adicionar uma nova editora a tabela ''editora''
CREATE PROCEDURE AdicionarEditora
    @Nome NVARCHAR(100),        -- Parâmetro para o nome da editora
    @Endereco NVARCHAR(255)     -- Parâmetro para o endereço da editora
AS
BEGIN
    -- Verifica se a editora já existe
    IF EXISTS (SELECT 1 FROM Editora WHERE Nome = @Nome)
    BEGIN
        RAISERROR('Editora já existe.', 16, 1);  -- Lança um erro se a editora existir
        RETURN;  -- Encerra a execução da procedure
    END

    -- Insere a nova editora
    INSERT INTO Editora (Nome, Endereco)
    VALUES (@Nome, @Endereco);
END;

-- Chamada da stored procedure
EXEC AdicionarEditora 
    @Nome = 'Maria Clara',         -- Nome da nova editora
    @Endereco = '20 de Setembro, 57'; -- Endereço da nova editora

--4 (11) Crie uma procedure para listar os libros por autores de uma nacionalidade especifica
CREATE PROCEDURE ListarLivrosPorNacionalidade
    @Nacionalidade NVARCHAR(100)  -- Parâmetro para a nacionalidade do autor
AS
BEGIN
    -- Seleciona os livros de autores da nacionalidade especificada
    SELECT L.Titulo, L.Ano, A.Nome AS Autor
    FROM Livro L
    JOIN Autor A ON L.AutorID = A.AutorID  -- Supondo que Livro tem uma chave estrangeira AutorID
    WHERE A.Nacionalidade = @Nacionalidade;
END;

-- Chamada da stored procedure
EXEC ListarLivrosPorNacionalidade 
    @Nacionalidade = 'Canada'; -- Exemplo de nacionalidade

--5 (17) Implemente uma procedure para remover um autor da lista de autores de um livro
CREATE PROCEDURE RemoverAutorDeLivro
    @LivroID INT,            -- Parâmetro para o ID do livro
    @AutorID INT             -- Parâmetro para o ID do autor
AS
BEGIN
    -- Verifica se a relação autor-livro existe
    IF NOT EXISTS (SELECT 1 FROM LivroAutor WHERE LivroID = @LivroID AND AutorID = @AutorID)
    BEGIN
        RAISERROR('Relação autor-livro não encontrada.', 16, 1);  -- Lança um erro se a relação não existir
        RETURN;  -- Encerra a execução da procedure
    END

    -- Remove a relação autor-livro
    DELETE FROM LivroAutor
    WHERE LivroID = @LivroID AND AutorID = @AutorID;
END;

-- Chamada da stored procedure
EXEC RemoverAutorDeLivro 
    @LivroID = 333,             -- ID do livro
    @AutorID = 777-666;             -- ID do autor

--6 (13) Crie uma procedure para excluir uma editora e atualizar os livros associados a essa editora
CREATE PROCEDURE ExcluirEditoraEAtualizarLivros
    @EditoraID INT              -- Parâmetro para o ID da editora a ser excluída
AS
BEGIN
    -- Verifica se a editora existe
    IF NOT EXISTS (SELECT 1 FROM Editora WHERE EditoraID = @EditoraID)
    BEGIN
        RAISERROR('Editora não encontrada.', 16, 1);  -- Lança um erro se a editora não existir
        RETURN;  -- Encerra a execução da procedure
    END

    -- Atualiza os livros associados à editora
    UPDATE Livro
    SET EditoraID = NULL         -- Ou defina para um valor padrão
    WHERE EditoraID = @EditoraID;

    -- Remove a editora
    DELETE FROM Editora
    WHERE EditoraID = @EditoraID;
END;

-- Chamada da stored procedure
EXEC ExcluirEditoraEAtualizarLivros 
    @EditoraID = 333;             

--7 (7) Crie uma procedure que liste os livros publicados em um ano especifico
CREATE PROCEDURE ListarLivrosPorAno
    @Ano INT                      -- Parâmetro para o ano de publicação
AS
BEGIN
    -- Seleciona os livros publicados no ano especificado
    SELECT Titulo, Ano, AutorID  -- Inclua outras colunas se necessário
    FROM Livro
    WHERE Ano = @Ano;
END;

-- Chamada da stored procedure
EXEC ListarLivrosPorAno 
    @Ano = 2023;                 -- Exemplo de ano

--8 (20) Implemente uma procedure para listar livros que nao tem uma editora especificada
CREATE PROCEDURE ListarLivrosSemEditora
    @EditoraID INT               -- Parâmetro para o ID da editora a ser verificada
AS
BEGIN
    -- Seleciona os livros que não têm a editora especificada
    SELECT Titulo, Ano, AutorID  -- Inclua outras colunas se necessário
    FROM Livro
    WHERE EditoraID IS NULL OR EditoraID <> @EditoraID;
END;

-- Chamada da stored procedure
EXEC ListarLivrosSemEditora 
    @EditoraID = 7;              -- Exemplo de ID da editora

--9 (18) Crie uma procedure para listar livros que tem mais de um autor
CREATE PROCEDURE ListarLivrosComMaisDeUmAutor
AS
BEGIN
    -- Seleciona os livros que têm mais de um autor
    SELECT L.Titulo, L.Ano, COUNT(A.AutorID) AS NumeroDeAutores
    FROM Livro L
    JOIN LivroAutor LA ON L.LivroID = LA.LivroID
    JOIN Autor A ON LA.AutorID = A.AutorID
    GROUP BY L.LivroID, L.Titulo, L.Ano
    HAVING COUNT(A.AutorID) > 1;  -- Filtra para incluir apenas livros com mais de um autor
END;

-- Chamada da stored procedure
EXEC ListarLivrosComMaisDeUmAutor;

--10 (14) Implemente uma procedure para listar autores juntamente com os titulos dos livros que eles escreveram
CREATE PROCEDURE ListarAutoresETitulos
AS
BEGIN
    -- Seleciona os autores e os títulos dos livros que escreveram
    SELECT A.Nome AS Autor, L.Titulo AS Livro
    FROM Autor A
    JOIN LivroAutor LA ON A.AutorID = LA.AutorID
    JOIN Livro L ON LA.LivroID = L.LivroID
    ORDER BY A.Nome;  -- Ordena pelo nome do autor
END;

-- Chamada da stored procedure
EXEC ListarAutoresETitulos;
