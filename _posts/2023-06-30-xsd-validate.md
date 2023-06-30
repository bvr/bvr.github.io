---
layout: post
title: XML Validation
published: yes
tags:
  - perl
  - XML::LibXML
  - XML
  - XSD
  - Schema
---
Having a XML file with defined structure, [XML Schema Definition Language (XSD)][1] provides nice way to define the structure and check the XML conforms to the definition. Suppose we have `config.xml` of this format

```xml
<?xml version="1.0" encoding="utf-8"?>
<DataCfg>
  <Setups>
    <Setup ID="1" Name="V1" Description="Variant 1" />
    <Setup ID="2" Name="V2" Description="Variant 2" />
  </Setups>
  <DataTypes>
    <DataType Name="uint32" CodeTypeName="uint32_T" Size="4" Min="0" Max="4294967295" />
    <DataType Name="int32" CodeTypeName="int32_T" Size="4" Min="-2147483648" Max="2147483647" />
    <DataType Name="boolean" CodeTypeName="boolean_T" Size="4" Min="0" Max="1" />
    <DataType Name="double" CodeTypeName="real_T" Size="4"  Min="-1.79769313486231e+308" Max="1.79769313486231e+308"/>
    <DataType Name="uint16" CodeTypeName="uint16_T" Size="2" Min="0" Max="65535" />
    <DataType Name="int16" CodeTypeName="int16_T" Size="2" Min="-32768" Max="32767" />
    <DataType Name="uint8" CodeTypeName="uint8_T" Size="1" Min="0" Max="255" />
    <DataType Name="int8" CodeTypeName="int8_T" Size="1" Min="-128" Max="127" />
  </DataTypes>
</DataCfg>
```

Tons of tools are available on web to generate the XSD, for instance [this one](https://www.freeformatter.com/xsd-generator.html). It allows to select from number of methods to construct the schema. Generally good idea after use of such tool is to walk over types and make them more specific. You get something like this and save it in `config.xsd` 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" elementFormDefault="qualified">
  <xs:element name="DataCfg">
    <xs:complexType>
      <xs:sequence>
        <xs:element ref="Setups"/>
        <xs:element ref="DataTypes"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
  <xs:element name="Setups">
    <xs:complexType>
      <xs:sequence>
        <xs:element maxOccurs="unbounded" ref="Setup"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
  <xs:element name="Setup">
    <xs:complexType>
      <xs:attribute name="ID" use="required"/>
      <xs:attribute name="Name" use="required"/>
      <xs:attribute name="Description" use="required"/>
    </xs:complexType>
  </xs:element>
  <xs:element name="DataTypes">
    <xs:complexType>
      <xs:sequence>
        <xs:element maxOccurs="unbounded" ref="DataType"/>
      </xs:sequence>
    </xs:complexType>
  </xs:element>
  <xs:element name="DataType">
    <xs:complexType>
      <xs:attribute name="Name" use="required"/>
      <xs:attribute name="CodeTypeName" use="required"/>
      <xs:attribute name="Size" use="required"/>
      <xs:attribute name="Min" use="required"/>
      <xs:attribute name="Max" use="required"/>
    </xs:complexType>
  </xs:element>
</xs:schema>
```

Validation is easy with [XML::LibXML][2] perl library

```perl
use XML::LibXML;
use Try::Tiny;

my $config_filename = 'config.xml';
my $dom    = XML::LibXML->load_xml(   location => $config_filename);
my $schema = XML::LibXML::Schema->new(location => 'config.xsd');
try { 
    $schema->validate($dom) 
}
catch {
    die "There is a problem with the configuration: $_";
};
print "The $config_filename is valid\n";
```

If there is something extra (like added `Component` node in `DataCfg` element), we get helpful message like

```
There is a problem with the configuration: config.xml:0: Schemas validity error : Element 'Component': This element is not expected.
```

[1]: https://www.w3.org/TR/xmlschema11-1/
[2]: https://metacpan.org/pod/XML::LibXML
