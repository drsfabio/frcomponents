# BGRABitmap tutorial 1

> Source: [BGRABitmap tutorial 1](https://wiki.freepascal.org/BGRABitmap_tutorial_1) · 5 min read

# BGRABitmap tutorial 1

    Jump to navigationJump to search

│      **[Deutsch (de)](https://wiki.freepascal.org/BGRABitmap_tutorial_1/de "BGRABitmap tutorial 1/de")** │  **English (en)** │   **[español (es)](https://wiki.freepascal.org/BGRABitmap_tutorial_1/es "BGRABitmap tutorial 1/es")** │    **[français (fr)](https://wiki.freepascal.org/BGRABitmap_tutorial_1/fr "BGRABitmap tutorial 1/fr")** │            **[русский (ru)](https://wiki.freepascal.org/BGRABitmap_tutorial_1/ru "BGRABitmap tutorial 1/ru")** │

[**Home**](https://wiki.freepascal.org/BGRABitmap_tutorial "BGRABitmap tutorial") | **Tutorial 1** | [**Tutorial 2**](https://wiki.freepascal.org/BGRABitmap_tutorial_2 "BGRABitmap tutorial 2") | [**Tutorial 3**](https://wiki.freepascal.org/BGRABitmap_tutorial_3 "BGRABitmap tutorial 3") | [**Tutorial 4**](https://wiki.freepascal.org/BGRABitmap_tutorial_4 "BGRABitmap tutorial 4") | [**Tutorial 5**](https://wiki.freepascal.org/BGRABitmap_tutorial_5 "BGRABitmap tutorial 5") | [**Tutorial 6**](https://wiki.freepascal.org/BGRABitmap_tutorial_6 "BGRABitmap tutorial 6") | [**Tutorial 7**](https://wiki.freepascal.org/BGRABitmap_tutorial_7 "BGRABitmap tutorial 7") | [**Tutorial 8**](https://wiki.freepascal.org/BGRABitmap_tutorial_8 "BGRABitmap tutorial 8") | [**Tutorial 9**](https://wiki.freepascal.org/BGRABitmap_tutorial_9 "BGRABitmap tutorial 9") | [**Tutorial 10**](https://wiki.freepascal.org/BGRABitmap_tutorial_10 "BGRABitmap tutorial 10") | [**Tutorial 11**](https://wiki.freepascal.org/BGRABitmap_tutorial_11 "BGRABitmap tutorial 11") | [**Tutorial 12**](https://wiki.freepascal.org/BGRABitmap_tutorial_12 "BGRABitmap tutorial 12") | [**Tutorial 13**](https://wiki.freepascal.org/BGRABitmap_tutorial_13 "BGRABitmap tutorial 13") | [**Tutorial 14**](https://wiki.freepascal.org/BGRABitmap_tutorial_14 "BGRABitmap tutorial 14") | [**Tutorial 15**](https://wiki.freepascal.org/BGRABitmap_tutorial_15 "BGRABitmap tutorial 15") | [**Tutorial 16**](https://wiki.freepascal.org/BGRABitmap_tutorial_16 "BGRABitmap tutorial 16") | [Edit](https://wiki.freepascal.org/index.php?title=Template:BGRABitmap_tutorial_index&action=edit)

This first tutorial shows you how to use [BGRABitmap](https://wiki.freepascal.org/BGRABitmap "BGRABitmap") library.

You can download the library on [GitHub](https://github.com/bgrabitmap).



## Contents



- 1 Create a new project
- 2 Add reference to BGRABitmap
   - 2.1 Alternative ways of referencing
      - 2.1.1 By installing BGRABitmap package
      - 2.1.2 By adding BGRABitmap units to the search path
- 3 Add some drawing
- 4 Resulting code
- 5 Run the program



### Create a new project



Create an windowed application with menu **Project > New project**.

The main form unit should look like this:



```
unit UMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs;

type

  { TForm1 }

  TForm1 = class(TForm)
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

initialization
  {$I UMain.lrs}

end.
```



If you do not find it, use **Ctrl-F12** to show file list.

Save your project next to BGRABitmap library with menu **File > Save all** (not necessarily in the same folder).



### Add reference to BGRABitmap



The first time you use BGRABitmap, open bgrabitmappack.lpk with Lazarus and click on "Use > Add to Project". Then, if you need to add the reference in another project, you can do it through the Project inspector and click on "Add... > New condition" and choose BGRABitmapPack.

In the unit clause, add a reference to BGRABitmap and BGRABitmapTypes after Dialogs.



```
uses
  Classes, SysUtils, FileUtil, LResources,
  Forms, Controls, Graphics, Dialogs,
  BGRABitmap, BGRABitmapTypes;
```



#### Alternative ways of referencing



##### By installing BGRABitmap package



Open bgrabitmappack.lpk as a package. Make sure it is possible to install it by going in the package window into "Options > IDE Integration" and setting the package type to "designtime and runtime". Then in the package window, click on install. A dialog pops up, asking if the package must be added to Lazarus and if it needs to be compiled again. Choose Yes twice.

If everything is fine, Lazarus restarts and BGRABitmap units are available. If it does not work, you can simply add BGRABitmap to the search path without compiling Lazarus.



##### By adding BGRABitmap units to the search path



Another way is to add BGRABitmap units to the search path of the project. To do this, go to compiler options with menu **Project > Compiler options**. In other unit files path, add the relative path to BGRABitmap. For example, if BGRABitmap is in a folder next to your project, the relative path could be "..\BGRABitmap".

If you copy BGRABitmap files in the same folder as your project, then you do not need to add such search path. However, it is not recommended because if you have multiple projects using the library, it could become a repetitive task to update to a new version of the library.

If you are lost with relative path, you can also add the relative path by adding the BGRABitmap unit to your project. To do so, open within your project the file bgrabitmap.pas. Then use menu **Project > Add file to project**. Lazarus will ask if you want to add the file and the new directory to the project.



### Add some drawing



Add a painting event. To do this, click on the form, then go to the object inspector, in the event tab, and double click on the OnPaint line. Lazarus will add automatically a FormPaint handler to the main form unit. Add for example the following code inside it:



```
procedure TForm1.FormPaint(Sender: TObject);
var bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(ClientWidth, ClientHeight, BGRABlack);
  bmp.FillRect(20, 20, 100, 40, BGRA(255,192,0), dmSet);  //fill an orange rectangle
  bmp.Draw(Canvas, 0, 0, True);                           //render BGRABitmap on the form
  bmp.Free;                                               //free memory
end;
```



As you can see, you need to define a [TBGRABitmap](https://wiki.freepascal.org/TBGRABitmap_class "TBGRABitmap class") variable and create it. There are several constructors for [TBGRABitmap](https://wiki.freepascal.org/TBGRABitmap_class "TBGRABitmap class"). The one used here creates a bitmap of size ClientWidth x ClientHeight and filled with black. ClientWidth and ClientHeight are form properties that return the available space for drawing inside the form.

The FillRect procedure takes usual parameters for drawing a rectangle, that is the upper-left corner followed by the lower-right corner plus 1. It means that the pixel at (100,40) is excluded from the rectangle.

After that, there is a color parameter with red/green/blue components, and a drawing mode. dmSet means to simply replace the pixels.

Do not forget to free the object after using it, to avoid a memory leak.



### Resulting code



You should obtain the following code:



```
unit UMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources,
  Forms, Controls, Graphics, Dialogs,
  BGRABitmap, BGRABitmapTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormPaint(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{ TForm1 }

procedure TForm1.FormPaint(Sender: TObject);
var bmp: TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(ClientWidth, ClientHeight, BGRABlack);
  bmp.FillRect(20, 20, 100, 40, BGRA(255, 192, 0), dmSet);
  bmp.Draw(Canvas, 0, 0, True);
  bmp.Free;
end;

initialization
  {$I UMain.lrs}

end.
```



### Run the program



You should obtain a window filled in black with an orange rectangle in it.

[![BGRATutorial1.png](https://wiki.freepascal.org/images/e/ea/BGRATutorial1.png)](https://wiki.freepascal.org/File:BGRATutorial1.png)

[Go to next tutorial (image loading)](https://wiki.freepascal.org/BGRABitmap_tutorial_2 "BGRABitmap tutorial 2")

      [Categories](https://wiki.freepascal.org/Special:Categories "Special:Categories"):

- [Graphics](https://wiki.freepascal.org/Category:Graphics "Category:Graphics")
- [BGRABitmap](https://wiki.freepascal.org/Category:BGRABitmap "Category:BGRABitmap")