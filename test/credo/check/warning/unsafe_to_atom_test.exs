defmodule Credo.Check.Warning.UnsafeToAtomTest do
  use Credo.TestHelper

  @described_check Credo.Check.Warning.UnsafeToAtom

  #
  # cases NOT raising issues
  #

  test "it should NOT report expected code" do
    """
    defmodule CredoSampleModule do
      def convert_module(parameter) do
        Module.safe_concat(__MODULE__, parameter)
      end

      def convert_module_2(parameter1, parameter2) do
        Module.safe_concat([__MODULE__, parameter1, parameter2])
      end

      def convert_atom(parameter) do
        String.to_existing_atom(parameter)
      end

      def convert_atom_2(parameter) do
        List.to_existing_atom(parameter)
      end

      def convert_erlang_list(parameter) do
        :erlang.list_to_existing_atom(parameter)
      end

      def convert_erlang_binary(parameter) do
        :erlang.binary_to_existing_atom(parameter, :utf8)
      end
    end
    """
    |> to_source_file()
    |> refute_issues(@described_check)
  end

  #
  # cases raising issues
  #

  test "it should report a violation" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter) do
        String.to_atom(parameter)
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "it should report a violation /2" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter) do
        List.to_atom(parameter)
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "it should report a violation /3" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter) do
        Module.concat(__MODULE__, parameter)
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "it should report a violation /4" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter1, parameter2) do
        Module.concat([__MODULE__, parameter1, parameter2])
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "it should report a violation /5" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter) do
        :erlang.list_to_atom(parameter)
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  test "it should report a violation /6" do
    """
    defmodule CredoSampleModule do
      def some_function(parameter) do
        :erlang.binary_to_atom(parameter, :utf8)
      end
    end
    """
    |> to_source_file()
    |> assert_issue(@described_check)
  end

  describe "Jason decode/decode!" do
    # Keys unspecified
    test "it should not report a violation on Jason.decode without keys with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode()
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode without keys without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode(parameter)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode! without keys with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode!()
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode! without keys without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode!(parameter)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    # keys: :atoms! (safe)
    test "it should not report a violation on Jason.decode with keys: :atoms! with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode(keys: :atoms!)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode with keys: :atoms! without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode(parameter, keys: :atoms!)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode! with keys: :atoms! with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode!(keys: :atoms!)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    test "it should not report a violation on Jason.decode! with keys: :atoms! without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode!(parameter, keys: :atoms!)
        end
      end
      """
      |> to_source_file()
      |> refute_issues(@described_check)
    end

    # keys: :atoms (unsafe)
    test "it should report a violation on Jason.decode with keys: :atoms!with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode(keys: :atoms)
        end
      end
      """
      |> to_source_file()
      |> assert_issue(@described_check)
    end

    test "it should report a violation on Jason.decode with keys: :atoms without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode(parameter, keys: :atoms)
        end
      end
      """
      |> to_source_file()
      |> assert_issue(@described_check)
    end

    test "it should report a violation on Jason.decode! with keys: :atoms with a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          parameter |> Jason.decode!(keys: :atoms)
        end
      end
      """
      |> to_source_file()
      |> assert_issue(@described_check)
    end

    test "it should report a violation on Jason.decode! with keys: :atoms without a pipeline" do
      """
      defmodule CredoSampleModule do
        def some_function(parameter) do
          Jason.decode!(parameter, keys: :atoms)
        end
      end
      """
      |> to_source_file()
      |> assert_issue(@described_check)
    end
  end
end
