<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:hkoll="hkoll">
    
    <!-- Output options -->
    <xsl:output method="html" indent="yes" media-type="application/html" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:key name="allAppsEnding" match="/tei:TEI/tei:text/tei:back/tei:listApp/tei:app" use="@to" />
    
    <!-- Root -->
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="/tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[1]" />
                </title>
            </head>
            <body>
                <div>
                    <xsl:apply-templates select="./tei:TEI/tei:text/tei:body" />
                </div>
            </body>
        </html>
    </xsl:template>
    
    <!-- TEI div elements reproduce the sections' structure -->
    <xsl:template match="tei:div">
        <div id="{@xml:id}">
            <h2>
                <xsl:choose>
                    <xsl:when test="boolean(@type)">
                        <xsl:value-of select="@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Anonymous Section</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </h2>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="tei:head">
        <h1>
            <xsl:value-of select="." />
        </h1>
    </xsl:template>
    
    <!-- Clauses/Sentences -->
    <xsl:template match="tei:cl">
        <span id="{@xml:id}">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    
    <!-- Words -->
    <xsl:template match="tei:w">
        <xsl:if test="not(preceding-sibling::*[1][@join = 'right' or @join = 'both'])">
            <span><xsl:text>&#32;</xsl:text></span>
        </xsl:if>
        <xsl:element name="span">
            <xsl:attribute name="id" select="@xml:id"/>
            <xsl:attribute name="title" select="@xml:id"/>
            <xsl:apply-templates />
        </xsl:element>
        <xsl:for-each select="key('allAppsEnding', concat('#', @xml:id))">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Punctuation -->
    <xsl:template match="tei:pc">
        <xsl:choose>
            <xsl:when test="not(@join = 'left' or @join = 'both')">
                <span><xsl:text>&#32;</xsl:text></span>
            </xsl:when>
        </xsl:choose>
        <span>
            <xsl:apply-templates />
        </span>
        <xsl:for-each select="key('allAppsEnding', concat('#', @xml:id))">
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <!--
         Keep attributes and nodes not matched otherwise (i.e. do not only take value).
         This allows XML/HTML formatting of the input to be forwarded to the edition.
    -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Format of apparatus entry for variants (for inline display) -->
    <xsl:template match="tei:app[@type='variant']">
        <div id="{@xml:id}">
            <ul>
                <!-- print lemma -->
                <xsl:variable name="lemma">
                    <xsl:choose>
                        <xsl:when test="tei:lem">
                            <xsl:sequence select="tei:lem" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&lt;lemma not defined&gt;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <li style="font-weight: bold">
                    <xsl:value-of select="concat($lemma, '] ')" />
                    <xsl:variable name="wits" select="$lemma/tei:lem/@wit" />
                    <xsl:value-of select="hkoll:prettyWits($wits)" />
                </li>
                
                <!-- print readings -->
                <xsl:for-each select="tei:rdg">
                    <li>
                        <xsl:choose>
                            <xsl:when test="@cause = 'omission'">
                                <em>om. </em>
                            </xsl:when>
                            <xsl:when test="@cause = 'addition'">
                                <!-- <xsl:value-of select="concat($lemma, ' ')"/> -->
                                <xsl:text>… </xsl:text>
                                <xsl:apply-templates select="." />
                                <xsl:text>] </xsl:text>
                                <em>add. </em>
                            </xsl:when>
                            <xsl:when test="@cause = 'transposition'">
                                <xsl:apply-templates select="." />
                                <xsl:text>] </xsl:text>
                                <em>transp. </em>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates />
                                <xsl:text>] </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:variable name="wits" select="@wit" />
                        <xsl:value-of select="hkoll:prettyWits($wits)" />
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    
    <!-- Format of any other standoff than variants -->
    <xsl:template match="tei:app">
        <div id="{@xml:id}" from="{@from}" to="{@to}" style="color: green; margin: 0.2em 2em;">
            <xsl:if test="@type">
                <div>[<xsl:value-of select="@type"/>]</div>
            </xsl:if>
            <xsl:apply-templates />
        </div>
    </xsl:template>
    
    <xsl:template match="tei:anchor">
        <xsl:for-each select="key('allAppsEnding', concat('#', @xml:id))">
            <xsl:apply-templates select="." />
        </xsl:for-each>
        <xsl:if test="not(@break = 'no')">
            <xsl:text>&#32;</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="tei:todo">
        <xsl:if test="@comment">
            <xsl:element name="abbr">
                <xsl:attribute name="title">
                    <xsl:value-of select="@comment" />
                </xsl:attribute>
                <xsl:text>(!)</xsl:text>
            </xsl:element>
        </xsl:if>
        <xsl:apply-templates />
    </xsl:template>
    
    <!-- ripHash: remove the # sign preceding an html:id -->
    <xsl:function name="hkoll:ripHash">
        <xsl:param name="idLabels" />
        <xsl:for-each select="$idLabels">
            <xsl:value-of select="substring(., 2)" />
        </xsl:for-each>
    </xsl:function> 
    
    <xsl:function name="hkoll:prettyWits">
        <xsl:param name="wits" />
        <xsl:sequence select="string-join(hkoll:ripHash(tokenize($wits, ' ')), ', ')" />
    </xsl:function>
    
</xsl:stylesheet>