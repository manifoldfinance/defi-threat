/**
 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019
 (UTC) */

pragma solidity ^0.5.0;

contract Certificates {

    struct Certificate {
        uint256 id;
        string name;
        string fileHash;
    }

    string public course = "Imersão em Blockchain: uma tecnologia disruptiva";
    string public issuer = "OnePercent | Blockchain Solutions";
    string public loadTime = "16 hours";
    uint256 public timestamp = now;
    mapping(uint256 => Certificate) public registry;

    constructor() public {
        init();
    }

    function init() private {
        register(2485849414, "Andre Luiz Gava", "Qmd69wJbhj7CvXWHCzpZ8GmERn4zLLsHqgJ6QxvzGvYWVt");
        register(2959266073, "Cledir Jose Scopel", "QmX8YtVKJdAEhchjvzUq1gryNv6wLyjQAHwyEC3uWmGRrH");
        register(8872385112, "Cristian de Oliveira", "QmNfDgW5f8i6S49DqjJ7XXezutaAiLvwARaybnecX3AF15");
        register(3109442327, "Cristian Ferrari", "QmWQr4FU7SEq5CU31oYqcAiDYZHm9ExcyvGchGFWxWTK1B");
        register(4171589508, "Diego Fabio Schuh", "QmUsGzxXMzwnoYYgbSWziQNbyLJgPpy8iSU7kqYpwPfU2N");
        register(6647262785, "Eduardo Franzen", "QmcEN72ZRQSZnJu9WgpbEMA2FQX14ZjnectDnu74RcyLP8");
        register(1369789686, "Janice Schmitz", "QmWJ9UT96Kus6u4uDBJv9p611o5CqjddpWH7xWqTRMrthT");
        register(3641683936, "Jhonatan Riboldi D Agostini Schmitz", "QmSCuNkmsTCiAR1GxsM2RePmVtWmUpDF7r17mzSZF7JSn7");
        register(9980379161, "Jhony Maiki Maseto", "QmR9AB3JyWFeai9WwYEaEMLNqhu4UxeZ976QGC6LHwhEyj");
        register(2088764279, "Julio Wilhelm Moerschbacher", "QmUaRtN4zoLUoVU2nmvpSjNkktdaVt52NkLHAiEfTp5yRY");
        register(5427656842, "Lissandro Machado Hoffmeister", "QmVdCjukCfokNbqFkdYS5uwTEFtfnAj6SBt9Qwo4oyDVFy");
        register(4859186050, "Patric Dalcin Venturini", "QmWvpvoCYbMXTTebF2Z4fqznwUtWf7jHAHrgfc3izHmMpd");
        register(5179616704, "Romulo Busatto", "QmYdm3LVtUBYD8Xixwi5xjc3rgJUSRHZiRC695rhfkzc3o");
        register(6098953930, "Tiago Ferigollo Cavalin", "QmZ7jWR5UDmAo3JVFBBsjd1fJJP2gdLuuCCSduiYgeNY1T");
        register(6370500881, "Tiago Malmham", "QmXt85t4s1XUsnhdYoC7NEbQLvynagkHCfDNEd7fgiGNHN");
        register(4900330890, "Willian Gustavo Mendo", "Qme85En6KJeYt6twApr2tqJMctjSEBZQWUg3hzFrLaRLrc");
    }

    function register(uint256 _id, string memory _name, string memory _fileHash) private {
        registry[_id] = Certificate(_id, _name, _fileHash);
    }

}