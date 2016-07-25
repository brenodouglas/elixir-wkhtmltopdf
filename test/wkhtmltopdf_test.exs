defmodule WkhtmltopdfTest do
  use ExUnit.Case
  import Wkhtmltopdf;
  doctest Wkhtmltopdf

  setup_all do
    File.touch("/tmp/page.html")  
  end

  test "Teste command with dpi" do
    command = open("/tmp/page.html") 
                  |> dpi(12)
                  |> path("/tmp/file.pdf")
                  |> command()
                  |> run()

    assert command == "wkhtmltopdf --dpi 12 /tmp/page.html /tmp/file.pdf"
  end

  test "Test html file not exists" do
    assert_raise Wkhtmltopdf.ExitException, fn -> 
      open("/tmp/filename.html")
    end
  end

  test "Test command with image params" do
    assert open("/tmp/page.html") 
            |> image_quality(100)
            |> image_dpi(800)
            |> path("/tmp/file.pdf")
            |> command(:true)  == "wkhtmltopdf --image-quality 100 --image-dpi 800 /tmp/page.html /tmp/file.pdf"
  end

  test "Test command with landscape and javascript options" do
    assert open("/tmp/page.html") 
            |> orientation("Landscape")
            |> javascript_delay(1000)
            |> path("/tmp/file.pdf")
            |> command(:true) == "wkhtmltopdf --orientation Landscape --javascript-delay 1000 /tmp/page.html /tmp/file.pdf"
  end
end