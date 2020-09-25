<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
<head>
<link type="text/css" rel="stylesheet" href="BuildAudit.css" />
</head>
<body class="Normal">
<xsl:for-each select="Tests">
<table ID="Heading">
	<tr>
		<td class="Title">Windows 10 Build Audit - <xsl:value-of select="@ScriptVersion"/></td>
		<td class="logo">&#160;</td>
	</tr>
</table>
	<table ID="Top">
		<tr class="Subtitle">
			<td class="Subtitle">&#160;</td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Machine Name</td><td> <xsl:value-of select="@System"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Audit Date</td><td> <xsl:value-of select="@RunDate"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Run By</td><td> <xsl:value-of select="@RunBy"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Test Success Rate</td><td> <xsl:value-of select="@TotalTests - @TotalErrors - @TotalWarnings"/>/<xsl:value-of select="@TotalTests"/></td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Total Test Errors</td><td> <xsl:value-of select="@TotalErrors"/> </td>
		</tr>
		<tr class="Subtitle">
			<td class="Subtitle">Total Test Warnings</td><td> <xsl:value-of select="@TotalWarnings"/> </td>
		</tr>
		<tr class="TableFooter"><td>&#160;</td></tr>
	</table>
	<table ID="TOC">
		<xsl:for-each select="Test">
			<tr class="TOC">
				<td class="TOC">
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:value-of select="concat('#',@Family)"/>
					</xsl:attribute>
					<xsl:attribute name="class">TOC</xsl:attribute>
				<xsl:value-of select="@Family"/>
				</xsl:element>
				</td>
				<td>
					<xsl:value-of select="count(TestInstance[@TestResult='OK'])" />/<xsl:value-of select="count(TestInstance)" />
				</td>
			</tr>
		</xsl:for-each>
		<tr class="TableFooter"><td>&#160;</td></tr>
	</table>
	<xsl:for-each select="Test">
		<table>
				<xsl:element name="tr">
					<xsl:attribute name="class">Header</xsl:attribute>
					<xsl:attribute name="ID">
						<xsl:value-of select="@Family"/>
					</xsl:attribute>
					<td><xsl:value-of select="@Family"/></td>
					<td align="right"><a href="#top" class="Header">top</a></td>
				</xsl:element>
		</table>
		<table>
			<tr class="TableHeader">
				<th class="col1">Test</th>
				<th class="col2">Result</th>
			</tr>
			<xsl:for-each select="TestInstance">
				<xsl:element name="tr">
					<xsl:attribute name="class">
						<xsl:value-of select="concat('TableRow',@TestResult)"/>
					</xsl:attribute>
					<xsl:element name="td">
						<xsl:attribute name="class">col1</xsl:attribute>
						<xsl:attribute name="title"><xsl:value-of select="@TestExplanation"/></xsl:attribute>
						<xsl:call-template name="replace-br">
							<xsl:with-param name="text" select="@TestName" />
						</xsl:call-template>
					</xsl:element>
					<xsl:element name="td">
						<xsl:attribute name="class">col2</xsl:attribute>
						<xsl:attribute name="title"><xsl:value-of select="@TestExpectedValue"/></xsl:attribute>
						<xsl:call-template name="replace-br">
							<xsl:with-param name="text" select="@TestValue"/>
						</xsl:call-template>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
			<tr class="TableFooter"><td>&#160;</td></tr>
		</table>
	</xsl:for-each>
</xsl:for-each>
</body>
</html>
</xsl:template>

<xsl:template name="replace-br">
	<xsl:param name="text"/>
	<xsl:choose>
		<xsl:when test="contains($text, '&#xD;&#xA;')">
			<xsl:value-of select="substring-before($text, '&#xD;&#xA;')"/>
			<br/>
			<xsl:call-template name="replace-br">
				<xsl:with-param name="text" select="substring-after($text,'&#xD;&#xA;')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

</xsl:stylesheet> 
