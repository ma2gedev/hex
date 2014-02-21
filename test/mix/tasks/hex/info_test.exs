defmodule Mix.Tasks.Hex.InfoTest do
  use HexTest.Case
  @moduletag :integration

  test "package" do
    Mix.Tasks.Hex.Info.run(["ex_doc"])

    assert_received { :mix_shell, :info, ["ex_doc"] }
    assert_received { :mix_shell, :info, ["  Contributors: John Doe, Jane Doe"] }
    assert_received { :mix_shell, :info, ["builds docs"] }

    Mix.Tasks.Hex.Info.run(["no_package"])
    assert_received { :mix_shell, :error, ["No package with name no_package"] }
  end

  test "release" do
    Mix.Tasks.Hex.Info.run(["ex_doc", "0.0.1"])
    assert_received { :mix_shell, :info, ["  Git ref: HEAD"] }

    Mix.Tasks.Hex.Info.run(["ex_doc", "1.2.3"])
    assert_received { :mix_shell, :error, ["No release with package name ex_doc and version 1.2.3"] }
  end

  test "general" do
    in_tmp fn _ ->
      System.put_env("MIX_HOME", System.cwd!)

      Mix.Tasks.Hex.Info.run([])
      assert_received { :mix_shell, :info, ["No registry file available, fetch it with 'mix hex.update'"] }

      Hex.API.get_registry(Hex.Registry.path)
      Mix.Tasks.Hex.Info.run([])
      assert_received { :mix_shell, :info, ["Registry file available (last updated: " <> _] }
      assert_received { :mix_shell, :info, ["Size: " <> _] }
      assert_received { :mix_shell, :info, ["Packages #: " <> _] }
      assert_received { :mix_shell, :info, ["Releases #: " <> _] }
    end
  after
    System.delete_env("MIX_HOME")
  end
end